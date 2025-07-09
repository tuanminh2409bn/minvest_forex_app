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
    const fileBucket = event.data.bucket;
    const filePath = event.data.name;
    const contentType = event.data.contentType;

    if (!filePath || !filePath.startsWith("verification_images/")) {
      functions.logger.log(`Bỏ qua file không liên quan: ${filePath}`);
      return null;
    }
    if (!contentType || !contentType.startsWith("image/")) {
      functions.logger.log(`Bỏ qua file không phải ảnh: ${contentType}`);
      return null;
    }

    const userId = filePath.split("/")[1].split(".")[0];
    functions.logger.log(`Bắt đầu xử lý ảnh cho user: ${userId}`);

    try {
      const [result] = await visionClient.textDetection(
        `gs://${fileBucket}/${filePath}`
      );
      const fullText = result.fullTextAnnotation?.text;

      if (!fullText) {
        throw new Error("Không đọc được văn bản nào từ ảnh.");
      }
      functions.logger.log("Văn bản đọc được:", fullText);

      // =========== CẬP NHẬT REGEX Ở ĐÂY ===========
      // Quy tắc mới cho phép phần "USD" là tùy chọn (không bắt buộc)
      const balanceRegex = /(\d{1,3}(?:,\d{3})*[.,]\d{2})(?:\s*USD)?/;
      const idRegex = /#\s*(\d{7,})/;

      const balanceMatch = fullText.match(balanceRegex);
      const idMatch = fullText.match(idRegex);

      if (!balanceMatch || !idMatch) {
        throw new Error("Không tìm thấy đủ thông tin Số dư và ID trong ảnh.");
      }

      const balanceString = balanceMatch[1].replace(/,/g, "");
      const balance = parseFloat(balanceString);
      const exnessId = idMatch[1];

      functions.logger.log(`Tìm thấy - Số dư: ${balance}, ID Exness: ${exnessId}`);

      const idDoc = await firestore
        .collection("verifiedExnessIds")
        .doc(exnessId).get();

      if (idDoc.exists) {
        throw new Error(`ID Exness ${exnessId} đã được sử dụng.`);
      }

      let tier = "demo";
      if (balance >= 500) {
        tier = "elite";
      } else if (balance >= 200) {
        tier = "vip";
      }

      functions.logger.log(`Phân quyền cho user ${userId}: ${tier}`);

      const userRef = firestore.collection("users").doc(userId);
      const idRef = firestore.collection("verifiedExnessIds").doc(exnessId);

      await Promise.all([
        userRef.set({subscriptionTier: tier}, {merge: true}),
        idRef.set({userId: userId, processedAt: admin.firestore.FieldValue.serverTimestamp()}),
      ]);

      functions.logger.log("Hoàn tất phân quyền thành công!");
      return null;
    } catch (error) {
      functions.logger.error("Xử lý ảnh thất bại:", error);
      await firestore.collection("users").doc(userId).set(
        {verificationStatus: "failed", verificationError: (error as Error).message},
        {merge: true}
      );
      return null;
    }
  });