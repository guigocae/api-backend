-- CreateEnum
CREATE TYPE "ClientType" AS ENUM ('PERSON', 'COMPANY');

-- CreateEnum
CREATE TYPE "RentalStatus" AS ENUM ('PENDING', 'CONFIRMED', 'IN_PROGRESS', 'FINISHED', 'CANCELED');

-- CreateEnum
CREATE TYPE "RentalChannel" AS ENUM ('WEB', 'MOBILE', 'ADMIN', 'API');

-- CreateEnum
CREATE TYPE "EquipmentStatus" AS ENUM ('AVAILABLE', 'RENTED', 'MAINTENANCE', 'SOLD', 'DISABLED');

-- CreateEnum
CREATE TYPE "PartStatus" AS ENUM ('AVAILABLE', 'MAINTENANCE', 'DISABLED');

-- CreateEnum
CREATE TYPE "FiscalDocType" AS ENUM ('IN', 'OUT');

-- CreateEnum
CREATE TYPE "WorkOrderType" AS ENUM ('MAINTENANCE', 'INSTALLATION', 'DISMANTLING', 'RECEIVING', 'PREVENTIVE');

-- CreateEnum
CREATE TYPE "WorkOrderStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'DONE', 'CANCELED');

-- CreateEnum
CREATE TYPE "SupportTicketStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'FINISHED', 'CANCELED');

-- CreateEnum
CREATE TYPE "AgendaItemKind" AS ENUM ('RENTAL_SETUP', 'RENTAL_TEARDOWN', 'SUPPORT_VISIT', 'MAINTENANCE_VISIT', 'NOTICE', 'PENDENCY');

-- CreateEnum
CREATE TYPE "AgendaItemStatus" AS ENUM ('PLANNED', 'DONE', 'CANCELED');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('MASTER', 'ADMIN', 'TECHNICIAN', 'LOGISTICS');

-- CreateEnum
CREATE TYPE "MaintenanceStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'FINISHED', 'CANCELED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'TECHNICIAN',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Client" (
    "id" UUID NOT NULL,
    "type" "ClientType" NOT NULL DEFAULT 'COMPANY',
    "companyName" TEXT,
    "name" TEXT NOT NULL,
    "document" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Client_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FiscalDoc" (
    "id" UUID NOT NULL,
    "type" "FiscalDocType" NOT NULL,
    "number" TEXT NOT NULL,
    "issuerName" TEXT,
    "issueDate" TIMESTAMPTZ(3),
    "fileUrl" TEXT,
    "fileKey" TEXT,
    "notes" TEXT,
    "createdByUserId" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "FiscalDoc_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EquipmentModel" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "category" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "EquipmentModel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Equipment" (
    "id" UUID NOT NULL,
    "modelId" UUID NOT NULL,
    "serial" TEXT NOT NULL,
    "description" TEXT,
    "status" "EquipmentStatus" NOT NULL DEFAULT 'AVAILABLE',
    "warrantyUntil" TIMESTAMPTZ(3),
    "createdByUserId" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Equipment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EquipmentSale" (
    "equipmentId" UUID NOT NULL,
    "fiscalDocOutId" UUID NOT NULL,
    "clientId" UUID NOT NULL,
    "soldAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,

    CONSTRAINT "EquipmentSale_pkey" PRIMARY KEY ("equipmentId")
);

-- CreateTable
CREATE TABLE "Rental" (
    "id" UUID NOT NULL,
    "clientId" UUID NOT NULL,
    "clientNameSnapshot" TEXT NOT NULL,
    "clientCompanySnapshot" TEXT,
    "eventName" TEXT NOT NULL,
    "venueName" TEXT NOT NULL,
    "eventCompany" TEXT,
    "addressLine1" TEXT NOT NULL,
    "addressLine2" TEXT,
    "city" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "contactName" TEXT NOT NULL,
    "contactEmail" TEXT,
    "contactPhone" TEXT,
    "notes" TEXT,
    "startAt" TIMESTAMPTZ(3) NOT NULL,
    "endAt" TIMESTAMPTZ(3) NOT NULL,
    "channel" "RentalChannel" NOT NULL DEFAULT 'WEB',
    "status" "RentalStatus" NOT NULL DEFAULT 'PENDING',
    "canceledAt" TIMESTAMPTZ(3),
    "finishedAt" TIMESTAMPTZ(3),
    "createdByUserId" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Rental_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RentalItem" (
    "id" UUID NOT NULL,
    "rentalId" UUID NOT NULL,
    "equipmentModelId" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,
    "notes" TEXT,

    CONSTRAINT "RentalItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RentalEquipment" (
    "id" UUID NOT NULL,
    "rentalId" UUID NOT NULL,
    "equipmentId" UUID NOT NULL,
    "rentalItemId" UUID NOT NULL,
    "assignedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "unassignedAt" TIMESTAMPTZ(3),
    "assignedByUserId" TEXT,

    CONSTRAINT "RentalEquipment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RentalFinancial" (
    "rentalId" UUID NOT NULL,
    "negotiatedTerms" TEXT,
    "subtotal" DECIMAL(12,2),
    "discount" DECIMAL(12,2),
    "total" DECIMAL(12,2),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "RentalFinancial_pkey" PRIMARY KEY ("rentalId")
);

-- CreateTable
CREATE TABLE "PartCategory" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "PartCategory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartModel" (
    "id" UUID NOT NULL,
    "categoryId" UUID NOT NULL,
    "brand" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "PartModel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Part" (
    "id" UUID NOT NULL,
    "serial" TEXT NOT NULL,
    "modelId" UUID NOT NULL,
    "status" "PartStatus" NOT NULL DEFAULT 'AVAILABLE',
    "fiscalDocInId" UUID NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Part_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EquipmentPart" (
    "id" UUID NOT NULL,
    "equipmentId" UUID NOT NULL,
    "partId" UUID NOT NULL,
    "installedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "removedAt" TIMESTAMPTZ(3),
    "installedByUserId" TEXT,
    "notes" TEXT,

    CONSTRAINT "EquipmentPart_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AgendaItem" (
    "id" UUID NOT NULL,
    "kind" "AgendaItemKind" NOT NULL,
    "status" "AgendaItemStatus" NOT NULL DEFAULT 'PLANNED',
    "title" TEXT NOT NULL,
    "startAt" TIMESTAMPTZ(3) NOT NULL,
    "endAt" TIMESTAMPTZ(3),
    "rentalId" UUID,
    "supportTicketId" UUID,
    "maintenanceId" UUID,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "AgendaItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkOrder" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "type" "WorkOrderType" NOT NULL,
    "status" "WorkOrderStatus" NOT NULL DEFAULT 'OPEN',
    "description" TEXT,
    "actionNotes" TEXT,
    "date" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" TEXT,
    "agendaItemId" UUID,
    "equipmentId" UUID,
    "witnessSignatureUrl" TEXT,
    "witnessName" TEXT,
    "witnessDocument" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "WorkOrder_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkOrderPhoto" (
    "id" UUID NOT NULL,
    "workOrderId" UUID NOT NULL,
    "url" TEXT NOT NULL,
    "fileKey" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WorkOrderPhoto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SupportTicket" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "status" "SupportTicketStatus" NOT NULL DEFAULT 'OPEN',
    "equipmentId" UUID NOT NULL,
    "clientId" UUID,
    "contactName" TEXT NOT NULL,
    "contactEmail" TEXT,
    "contactPhone" TEXT,
    "notes" TEXT,
    "solution" TEXT,
    "openedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closedAt" TIMESTAMPTZ(3),
    "slaMinutes" INTEGER,
    "slaDueAt" TIMESTAMPTZ(3),
    "executionAt" TIMESTAMPTZ(3),
    "createdByUserId" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "SupportTicket_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Maintenance" (
    "id" UUID NOT NULL,
    "equipmentId" UUID NOT NULL,
    "status" "MaintenanceStatus" NOT NULL DEFAULT 'OPEN',
    "description" TEXT,
    "openedAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closedAt" TIMESTAMPTZ(3),
    "scheduledAt" TIMESTAMPTZ(3),
    "createdByUserId" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Maintenance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" UUID NOT NULL,
    "actorUserId" TEXT,
    "action" TEXT NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "data" JSONB NOT NULL,
    "ip" TEXT,
    "userAgent" TEXT,
    "occurredAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Client_document_key" ON "Client"("document");

-- CreateIndex
CREATE INDEX "Client_name_idx" ON "Client"("name");

-- CreateIndex
CREATE INDEX "Client_companyName_idx" ON "Client"("companyName");

-- CreateIndex
CREATE INDEX "FiscalDoc_type_idx" ON "FiscalDoc"("type");

-- CreateIndex
CREATE INDEX "FiscalDoc_number_idx" ON "FiscalDoc"("number");

-- CreateIndex
CREATE UNIQUE INDEX "FiscalDoc_type_number_key" ON "FiscalDoc"("type", "number");

-- CreateIndex
CREATE INDEX "EquipmentModel_isActive_idx" ON "EquipmentModel"("isActive");

-- CreateIndex
CREATE INDEX "EquipmentModel_name_idx" ON "EquipmentModel"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Equipment_serial_key" ON "Equipment"("serial");

-- CreateIndex
CREATE INDEX "Equipment_modelId_idx" ON "Equipment"("modelId");

-- CreateIndex
CREATE INDEX "Equipment_status_idx" ON "Equipment"("status");

-- CreateIndex
CREATE INDEX "EquipmentSale_clientId_idx" ON "EquipmentSale"("clientId");

-- CreateIndex
CREATE INDEX "EquipmentSale_fiscalDocOutId_idx" ON "EquipmentSale"("fiscalDocOutId");

-- CreateIndex
CREATE INDEX "Rental_clientId_startAt_idx" ON "Rental"("clientId", "startAt");

-- CreateIndex
CREATE INDEX "Rental_startAt_idx" ON "Rental"("startAt");

-- CreateIndex
CREATE INDEX "Rental_endAt_idx" ON "Rental"("endAt");

-- CreateIndex
CREATE INDEX "Rental_status_idx" ON "Rental"("status");

-- CreateIndex
CREATE INDEX "RentalItem_equipmentModelId_idx" ON "RentalItem"("equipmentModelId");

-- CreateIndex
CREATE UNIQUE INDEX "RentalItem_rentalId_equipmentModelId_key" ON "RentalItem"("rentalId", "equipmentModelId");

-- CreateIndex
CREATE INDEX "RentalEquipment_equipmentId_idx" ON "RentalEquipment"("equipmentId");

-- CreateIndex
CREATE INDEX "RentalEquipment_rentalId_idx" ON "RentalEquipment"("rentalId");

-- CreateIndex
CREATE INDEX "RentalEquipment_rentalItemId_idx" ON "RentalEquipment"("rentalItemId");

-- CreateIndex
CREATE UNIQUE INDEX "RentalEquipment_rentalId_equipmentId_key" ON "RentalEquipment"("rentalId", "equipmentId");

-- CreateIndex
CREATE UNIQUE INDEX "PartCategory_name_key" ON "PartCategory"("name");

-- CreateIndex
CREATE INDEX "PartModel_categoryId_idx" ON "PartModel"("categoryId");

-- CreateIndex
CREATE INDEX "PartModel_name_idx" ON "PartModel"("name");

-- CreateIndex
CREATE UNIQUE INDEX "PartModel_categoryId_brand_name_key" ON "PartModel"("categoryId", "brand", "name");

-- CreateIndex
CREATE UNIQUE INDEX "Part_serial_key" ON "Part"("serial");

-- CreateIndex
CREATE INDEX "Part_modelId_idx" ON "Part"("modelId");

-- CreateIndex
CREATE INDEX "Part_status_idx" ON "Part"("status");

-- CreateIndex
CREATE INDEX "Part_fiscalDocInId_idx" ON "Part"("fiscalDocInId");

-- CreateIndex
CREATE INDEX "EquipmentPart_equipmentId_idx" ON "EquipmentPart"("equipmentId");

-- CreateIndex
CREATE INDEX "EquipmentPart_partId_idx" ON "EquipmentPart"("partId");

-- CreateIndex
CREATE INDEX "AgendaItem_kind_startAt_idx" ON "AgendaItem"("kind", "startAt");

-- CreateIndex
CREATE INDEX "AgendaItem_status_idx" ON "AgendaItem"("status");

-- CreateIndex
CREATE INDEX "AgendaItem_rentalId_idx" ON "AgendaItem"("rentalId");

-- CreateIndex
CREATE UNIQUE INDEX "WorkOrder_number_key" ON "WorkOrder"("number");

-- CreateIndex
CREATE INDEX "WorkOrder_type_idx" ON "WorkOrder"("type");

-- CreateIndex
CREATE INDEX "WorkOrder_status_idx" ON "WorkOrder"("status");

-- CreateIndex
CREATE INDEX "WorkOrder_agendaItemId_idx" ON "WorkOrder"("agendaItemId");

-- CreateIndex
CREATE INDEX "WorkOrderPhoto_workOrderId_idx" ON "WorkOrderPhoto"("workOrderId");

-- CreateIndex
CREATE UNIQUE INDEX "SupportTicket_number_key" ON "SupportTicket"("number");

-- CreateIndex
CREATE INDEX "SupportTicket_equipmentId_idx" ON "SupportTicket"("equipmentId");

-- CreateIndex
CREATE INDEX "SupportTicket_clientId_idx" ON "SupportTicket"("clientId");

-- CreateIndex
CREATE INDEX "SupportTicket_status_idx" ON "SupportTicket"("status");

-- CreateIndex
CREATE INDEX "SupportTicket_executionAt_idx" ON "SupportTicket"("executionAt");

-- CreateIndex
CREATE INDEX "Maintenance_equipmentId_idx" ON "Maintenance"("equipmentId");

-- CreateIndex
CREATE INDEX "Maintenance_status_idx" ON "Maintenance"("status");

-- CreateIndex
CREATE INDEX "Maintenance_scheduledAt_idx" ON "Maintenance"("scheduledAt");

-- CreateIndex
CREATE INDEX "AuditLog_actorUserId_idx" ON "AuditLog"("actorUserId");

-- CreateIndex
CREATE INDEX "AuditLog_entityType_entityId_idx" ON "AuditLog"("entityType", "entityId");

-- CreateIndex
CREATE INDEX "AuditLog_occurredAt_idx" ON "AuditLog"("occurredAt");

-- AddForeignKey
ALTER TABLE "FiscalDoc" ADD CONSTRAINT "FiscalDoc_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Equipment" ADD CONSTRAINT "Equipment_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "EquipmentModel"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Equipment" ADD CONSTRAINT "Equipment_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EquipmentSale" ADD CONSTRAINT "EquipmentSale_equipmentId_fkey" FOREIGN KEY ("equipmentId") REFERENCES "Equipment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EquipmentSale" ADD CONSTRAINT "EquipmentSale_fiscalDocOutId_fkey" FOREIGN KEY ("fiscalDocOutId") REFERENCES "FiscalDoc"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EquipmentSale" ADD CONSTRAINT "EquipmentSale_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Rental" ADD CONSTRAINT "Rental_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Rental" ADD CONSTRAINT "Rental_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RentalItem" ADD CONSTRAINT "RentalItem_rentalId_fkey" FOREIGN KEY ("rentalId") REFERENCES "Rental"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RentalItem" ADD CONSTRAINT "RentalItem_equipmentModelId_fkey" FOREIGN KEY ("equipmentModelId") REFERENCES "EquipmentModel"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RentalEquipment" ADD CONSTRAINT "RentalEquipment_rentalId_fkey" FOREIGN KEY ("rentalId") REFERENCES "Rental"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RentalEquipment" ADD CONSTRAINT "RentalEquipment_equipmentId_fkey" FOREIGN KEY ("equipmentId") REFERENCES "Equipment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RentalEquipment" ADD CONSTRAINT "RentalEquipment_rentalItemId_fkey" FOREIGN KEY ("rentalItemId") REFERENCES "RentalItem"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RentalEquipment" ADD CONSTRAINT "RentalEquipment_assignedByUserId_fkey" FOREIGN KEY ("assignedByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RentalFinancial" ADD CONSTRAINT "RentalFinancial_rentalId_fkey" FOREIGN KEY ("rentalId") REFERENCES "Rental"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartModel" ADD CONSTRAINT "PartModel_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "PartCategory"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Part" ADD CONSTRAINT "Part_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "PartModel"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Part" ADD CONSTRAINT "Part_fiscalDocInId_fkey" FOREIGN KEY ("fiscalDocInId") REFERENCES "FiscalDoc"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EquipmentPart" ADD CONSTRAINT "EquipmentPart_equipmentId_fkey" FOREIGN KEY ("equipmentId") REFERENCES "Equipment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EquipmentPart" ADD CONSTRAINT "EquipmentPart_partId_fkey" FOREIGN KEY ("partId") REFERENCES "Part"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EquipmentPart" ADD CONSTRAINT "EquipmentPart_installedByUserId_fkey" FOREIGN KEY ("installedByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AgendaItem" ADD CONSTRAINT "AgendaItem_rentalId_fkey" FOREIGN KEY ("rentalId") REFERENCES "Rental"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AgendaItem" ADD CONSTRAINT "AgendaItem_supportTicketId_fkey" FOREIGN KEY ("supportTicketId") REFERENCES "SupportTicket"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AgendaItem" ADD CONSTRAINT "AgendaItem_maintenanceId_fkey" FOREIGN KEY ("maintenanceId") REFERENCES "Maintenance"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkOrder" ADD CONSTRAINT "WorkOrder_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkOrder" ADD CONSTRAINT "WorkOrder_agendaItemId_fkey" FOREIGN KEY ("agendaItemId") REFERENCES "AgendaItem"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkOrder" ADD CONSTRAINT "WorkOrder_equipmentId_fkey" FOREIGN KEY ("equipmentId") REFERENCES "Equipment"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WorkOrderPhoto" ADD CONSTRAINT "WorkOrderPhoto_workOrderId_fkey" FOREIGN KEY ("workOrderId") REFERENCES "WorkOrder"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupportTicket" ADD CONSTRAINT "SupportTicket_equipmentId_fkey" FOREIGN KEY ("equipmentId") REFERENCES "Equipment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupportTicket" ADD CONSTRAINT "SupportTicket_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SupportTicket" ADD CONSTRAINT "SupportTicket_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Maintenance" ADD CONSTRAINT "Maintenance_equipmentId_fkey" FOREIGN KEY ("equipmentId") REFERENCES "Equipment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Maintenance" ADD CONSTRAINT "Maintenance_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
