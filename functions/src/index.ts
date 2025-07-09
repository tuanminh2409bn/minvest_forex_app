import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";
import {ImageAnnotatorClient} from "@google-cloud/vision";
import {onObjectFinalized} from "firebase-functions/v2/storage";

// Khởi tạo Firebase Admin và Vision Client
admin.initializeApp();
const firestore = admin.firestore();
const visionClient = new ImageAnnotatorClient();

// Sử dụng cú pháp v2 onObjectFinalized
export const processVerificationImage = onObjectFinalized(
  { region: "asia-southeast1", cpu: 2 },
  async (event) => {
  // Lấy thông tin file từ event
  const fileBucket = event.data.bucket;
  const filePath = event.data.name;
  const contentType = event.data.contentType;

  // Chỉ xử lý các file ảnh trong thư mục 'verification_images/'
  if (!filePath || !filePath.startsWith("verification_images/")) {
    functions.logger.log(`Bỏ qua file không liên quan: ${filePath}`);
    return null;
  }
  if (!contentType || !contentType.startsWith("image/")) {
    functions.logger.log(`Bỏ qua file không phải ảnh: ${contentType}`);
    return null;
  }

  // Lấy User ID từ tên file (ví dụ: verification_images/USER_ID.jpg)
  const userId = filePath.split("/")[1].split(".")[0];
  functions.logger.log(`Bắt đầu xử lý ảnh cho user: ${userId}`);

  try {
    // 1. Dùng Vision AI để đọc văn bản từ ảnh
    const [result] = await visionClient.textDetection(
      `gs://${fileBucket}/${filePath}`
    );
    const fullText = result.fullTextAnnotation?.text;

    if (!fullText) {
      throw new Error("Không đọc được văn bản nào từ ảnh.");
    }
    functions.logger.log("Văn bản đọc được:", fullText);

    // 2. Phân tích văn bản để tìm Số dư và ID
    const balanceRegex = /(\d{1,3}(?:,\d{3})*[.,]\d{2})\s*USD/;
    const idRegex = /#\s*(\d{7,})/; // Tìm ID có ít nhất 7 chữ số

    const balanceMatch = fullText.match(balanceRegex);
    const idMatch = fullText.match(idRegex);

    if (!balanceMatch || !idMatch) {
      throw new Error("Không tìm thấy đủ thông tin Số dư và ID trong ảnh.");
    }

    const balanceString = balanceMatch[1].replace(/,/g, "");
    const balance = parseFloat(balanceString);
    const exnessId = idMatch[1];

    functions.logger.log(`Tìm thấy - Số dư: ${balance}, ID Exness: ${exnessId}`);

    // 3. Kiểm tra xem ID Exness này đã được dùng chưa
    const idDoc = await firestore
      .collection("verifiedExnessIds")
      .doc(exnessId).get();

    if (idDoc.exists) {
      throw new Error(`ID Exness ${exnessId} đã được sử dụng.`);
    }

    // 4. Gán quyền dựa trên số dư
    let tier = "demo";
    if (balance >= 500) {
      tier = "elite";
    } else if (balance >= 200) {
      tier = "vip";
    }

    functions.logger.log(`Phân quyền cho user ${userId}: ${tier}`);

    // 5. Cập nhật quyền cho user và lưu lại ID đã dùng
    const userRef = firestore.collection("users").doc(userId);
    const idRef = firestore.collection("verifiedExnessIds").doc(exnessId);

    // Dùng Promise.all để chạy song song
    await Promise.all([
      userRef.set({subscriptionTier: tier}, {merge: true}),
      idRef.set({userId: userId, processedAt: admin.firestore.FieldValue.serverTimestamp()}),
    ]);

    functions.logger.log("Hoàn tất phân quyền thành công!");
    return null;
  } catch (error) {
    functions.logger.error("Xử lý ảnh thất bại:", error);
    // Cập nhật trạng thái lỗi cho user
    await firestore.collection("users").doc(userId).set(
      {verificationStatus: "failed", verificationError: (error as Error).message},
      {merge: true}
    );
    return null;
  }
});