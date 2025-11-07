/*
  Warnings:

  - The primary key for the `Device` table will be changed. If it partially fails, the table could be left without primary key constraint.

*/
-- DropForeignKey
ALTER TABLE "ClipboardItem" DROP CONSTRAINT "ClipboardItem_deviceId_fkey";

-- DropForeignKey
ALTER TABLE "DeviceSession" DROP CONSTRAINT "DeviceSession_deviceId_fkey";

-- AlterTable
ALTER TABLE "ClipboardItem" ALTER COLUMN "deviceId" SET DATA TYPE TEXT;

-- AlterTable
ALTER TABLE "Device" DROP CONSTRAINT "Device_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ADD CONSTRAINT "Device_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "Device_id_seq";

-- AlterTable
ALTER TABLE "DeviceSession" ALTER COLUMN "deviceId" SET DATA TYPE TEXT;

-- AddForeignKey
ALTER TABLE "ClipboardItem" ADD CONSTRAINT "ClipboardItem_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "Device"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DeviceSession" ADD CONSTRAINT "DeviceSession_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "Device"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
