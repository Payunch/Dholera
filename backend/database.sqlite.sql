BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Analytics" (
	"id"	INTEGER,
	"date"	DATE NOT NULL UNIQUE,
	"pageVisits"	INTEGER DEFAULT 0,
	"uniqueVisitors"	INTEGER DEFAULT 0,
	"avgSessionDuration"	FLOAT DEFAULT '0',
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "AuditLogs" (
	"id"	INTEGER,
	"eventType"	VARCHAR(255) NOT NULL,
	"actorType"	VARCHAR(255) NOT NULL DEFAULT 'system',
	"actorId"	VARCHAR(255),
	"success"	TINYINT(1) NOT NULL DEFAULT 1,
	"ip"	VARCHAR(255),
	"userAgent"	VARCHAR(255),
	"details"	TEXT,
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Leads" (
	"id"	INTEGER,
	"name"	VARCHAR(255) NOT NULL,
	"phone"	VARCHAR(255) NOT NULL,
	"email"	VARCHAR(255),
	"source"	VARCHAR(255) DEFAULT 'Website',
	"timeSpent"	INTEGER DEFAULT 0,
	"status"	VARCHAR(255) NOT NULL DEFAULT 'New',
	"visited_pages"	TEXT,
	"notes"	TEXT,
	"last_contacted"	DATETIME,
	"verified"	TINYINT(1) DEFAULT 0,
	"returning_visitor"	TINYINT(1) DEFAULT 0,
	"visit_count"	INTEGER DEFAULT 1,
	"lead_token"	VARCHAR(255) UNIQUE,
	"browserFingerprint"	VARCHAR(255),
	"otp"	VARCHAR(255),
	"otp_expiry"	DATETIME,
	"high_interest_whatsapp_notified_at"	DATETIME,
	"high_interest_email_notified_at"	DATETIME,
	"whatsapp_sent_count"	INTEGER DEFAULT 0,
	"last_whatsapp_sent"	DATETIME,
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Leads_backup" (
	"id"	INTEGER,
	"name"	VARCHAR(255) NOT NULL,
	"phone"	VARCHAR(255) NOT NULL,
	"email"	VARCHAR(255),
	"source"	VARCHAR(255) DEFAULT 'Website',
	"timeSpent"	INTEGER DEFAULT '0',
	"status"	VARCHAR(255) NOT NULL DEFAULT 'New',
	"visited_pages"	TEXT,
	"notes"	TEXT,
	"last_contacted"	DATETIME,
	"verified"	TINYINT(1) DEFAULT 0,
	"returning_visitor"	TINYINT(1) DEFAULT 0,
	"visit_count"	INTEGER DEFAULT '1',
	"lead_token"	VARCHAR(255) UNIQUE,
	"browserFingerprint"	VARCHAR(255),
	"otp"	VARCHAR(255),
	"otp_expiry"	DATETIME,
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	"high_interest_whatsapp_notified_at"	DATETIME,
	"high_interest_email_notified_at"	DATETIME,
	"whatsapp_sent_count"	INTEGER DEFAULT '0',
	"last_whatsapp_sent"	DATETIME,
	PRIMARY KEY("id")
);
CREATE TABLE IF NOT EXISTS "PdfDocuments" (
	"id"	INTEGER,
	"title"	VARCHAR(255) NOT NULL,
	"category"	VARCHAR(255),
	"file_path"	VARCHAR(255) NOT NULL,
	"is_protected"	TINYINT(1) DEFAULT 1,
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "PdfViews" (
	"id"	INTEGER,
	"viewed_at"	DATETIME,
	"time_spent"	INTEGER DEFAULT 0,
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	"lead_id"	INTEGER,
	"pdf_id"	INTEGER,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("lead_id") REFERENCES "Leads"("id") ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY("pdf_id") REFERENCES "PdfDocuments"("id") ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS "Settings" (
	"id"	INTEGER,
	"key"	VARCHAR(255) NOT NULL UNIQUE,
	"value"	TEXT,
	"category"	VARCHAR(255) DEFAULT 'general',
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Updates" (
	"id"	INTEGER,
	"title"	VARCHAR(255) NOT NULL,
	"content"	TEXT NOT NULL,
	"category"	VARCHAR(255) NOT NULL DEFAULT 'General',
	"imageUrl"	VARCHAR(255),
	"published"	TINYINT(1) NOT NULL DEFAULT 1,
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "VisitorSessions" (
	"id"	INTEGER,
	"sessionId"	VARCHAR(255) NOT NULL UNIQUE,
	"timeSpent"	INTEGER DEFAULT 0,
	"visitedPages"	TEXT DEFAULT '[]',
	"source"	VARCHAR(255),
	"deviceType"	VARCHAR(255),
	"browserFingerprint"	VARCHAR(255),
	"ip"	VARCHAR(255),
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "WhatsAppLogs" (
	"id"	INTEGER,
	"lead_id"	INTEGER NOT NULL,
	"message_sent"	TINYINT(1) NOT NULL DEFAULT 1,
	"message_type"	VARCHAR(255) NOT NULL DEFAULT 'manual',
	"template_name"	VARCHAR(255),
	"status"	VARCHAR(255) DEFAULT 'clicked',
	"createdAt"	DATETIME NOT NULL,
	"updatedAt"	DATETIME NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("lead_id") REFERENCES "Leads"("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "AuditLogs" VALUES (1,'lead.notes.updated','admin','admin',1,'::1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','{"leadId":2}','2026-05-04 18:51:31.263 +00:00','2026-05-04 18:51:31.263 +00:00');
INSERT INTO "AuditLogs" VALUES (2,'admin.login.success','admin','admin',1,'::1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','{"mfaEnabled":false,"authMethod":"session+jwt"}','2026-05-05 12:38:20.900 +00:00','2026-05-05 12:38:20.900 +00:00');
INSERT INTO "AuditLogs" VALUES (3,'lead.otp.send.success','lead','7096571613',1,'::1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','{"fallback":false}','2026-05-05 12:58:28.396 +00:00','2026-05-05 12:58:28.396 +00:00');
INSERT INTO "AuditLogs" VALUES (4,'lead.save.direct.success','lead','7096571613',1,'::1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','{"source":"Direct Save"}','2026-05-05 13:11:04.281 +00:00','2026-05-05 13:11:04.281 +00:00');
INSERT INTO "AuditLogs" VALUES (5,'admin.login.success','admin','admin',1,'::1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','{"mfaEnabled":false,"authMethod":"session+jwt"}','2026-05-05 13:13:50.897 +00:00','2026-05-05 13:13:50.897 +00:00');
INSERT INTO "AuditLogs" VALUES (6,'admin.login.success','admin','admin',1,'::1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','{"mfaEnabled":false,"authMethod":"session+jwt"}','2026-05-05 13:48:41.864 +00:00','2026-05-05 13:48:41.864 +00:00');
INSERT INTO "AuditLogs" VALUES (7,'lead.save.direct.success','lead','7096571613',1,'::1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','{"source":"Direct Save","leadId":3}','2026-05-05 14:08:00.527 +00:00','2026-05-05 14:08:00.527 +00:00');
INSERT INTO "AuditLogs" VALUES (8,'admin.login.success','admin','admin',1,'::1','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','{"mfaEnabled":false,"authMethod":"session+jwt"}','2026-05-05 14:15:08.833 +00:00','2026-05-05 14:15:08.833 +00:00');
INSERT INTO "Leads" VALUES (1,'Rahul Patel','9876543210','rahul@gmail.com','PDF Verification',145,'New','["/","/planning"]','Interested in TP 1.',NULL,1,1,1,'token123','fp_test1',NULL,NULL,NULL,NULL,0,NULL,'2026-05-04 18:50:21.945 +00:00','2026-05-04 18:50:21.945 +00:00');
INSERT INTO "Leads" VALUES (2,'Priya Shah','9876543211','priya@gmail.com','Facebook',320,'Contacted','["/","/investment","/contact"]','Requested callback tomorrow.',NULL,0,0,1,NULL,'fp_test2',NULL,NULL,NULL,NULL,0,NULL,'2026-05-04 18:50:21.945 +00:00','2026-05-04 18:50:21.945 +00:00');
INSERT INTO "Leads" VALUES (3,'Paresh Solanki','7096571613','solankiparesh1183@gmail.com','OTP Verification',3415,'New','["/planning","/updates","/investment"]',NULL,'2026-05-05 14:23:19.242 +00:00',1,1,5,'4d8e5a8e9bb343be4af5ba3634305b29','fp_mou4qc','58768c9c4a45f0dcc90d6eb3f6da04f49f04d07a5d38ec4447bdf39e2abd720e','2026-05-05 13:03:26.716 +00:00',NULL,NULL,0,NULL,'2026-05-05 12:58:27.435 +00:00','2026-05-05 14:23:19.242 +00:00');
INSERT INTO "Leads_backup" VALUES (1,'Diag','9876543210','diag@example.com','PDF Verification',145,'New','["/","/planning"]','Interested in TP 1.',NULL,1,1,2,'cf9c3af8f3f1e0bdcb73732e6145a5a4','fp_diag','d4b02267b57b674e90965d44bffa9b9d8f96f0691bcdf9c1bd5f7dd082ad9c53','2026-05-03 18:37:50.136 +00:00','2026-05-03 18:05:00.658 +00:00','2026-05-03 18:32:50.138 +00:00',NULL,NULL,0,NULL);
INSERT INTO "Leads_backup" VALUES (2,'Priya Shah','9876543211','priya@gmail.com','Facebook',320,'Contacted','["/","/investment","/contact"]','Requested callback tomorrow.',NULL,0,0,1,NULL,'fp_test2',NULL,NULL,'2026-05-03 18:05:00.658 +00:00','2026-05-03 18:05:00.658 +00:00',NULL,NULL,0,NULL);
INSERT INTO "Leads_backup" VALUES (3,'NoPdf User','9123456789','nopdf@example.com','OTP Verification',0,'New',NULL,NULL,NULL,0,0,1,NULL,'fp_nopdf123','9c9940ea6e2dc9af22b2fb67f4589a17f49086af5eeac6fb490159e9668da59c','2026-05-03 18:32:34.346 +00:00','2026-05-03 18:27:34.351 +00:00','2026-05-03 18:27:34.351 +00:00',NULL,NULL,0,NULL);
INSERT INTO "Leads_backup" VALUES (4,'Pdf Test','9998887776','pdf@test.com','Diag',0,'New','[]',NULL,NULL,1,1,4,'1c881713174918266065175dd94c9678',NULL,NULL,NULL,'2026-05-03 18:33:04.408 +00:00','2026-05-03 18:36:09.626 +00:00',NULL,NULL,0,NULL);
INSERT INTO "Leads_backup" VALUES (5,'Paresh Solanki','9987654321','solankiparesh1183@gmail.com','OTP Verification',0,'New',NULL,NULL,NULL,0,0,1,NULL,'fp_mou4qc','e33963941457ec151fa9664bf27e2d689c8541f95951c22b4c3488621a9fbf59','2026-05-03 19:19:15.797 +00:00','2026-05-03 19:14:16.282 +00:00','2026-05-03 19:14:16.282 +00:00',NULL,NULL,0,NULL);
INSERT INTO "Leads_backup" VALUES (6,'Paresh Solanki','7096571613','solankiparesh1183@gmail.com','OTP Verification',9645,'New','["/planning","/admin","/","/admin/login","/admin/leads","/admin/updates","/updates","/investment"]',NULL,'2026-05-04 17:29:53.268 +00:00',1,1,4,'5b2acda70e55d3693f3fd99d3598daad','fp_mou4qc',NULL,NULL,'2026-05-03 19:15:33.837 +00:00','2026-05-04 17:29:53.268 +00:00',NULL,NULL,0,NULL);
INSERT INTO "PdfDocuments" VALUES (1,'New DP Plan 2026','DP Maps','uploads/pdfs/New_DP.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (2,'Dholera DP Map - Zone Hath','DP Maps','uploads/pdfs/d.p zone hath and resurwey number ok-Model.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (3,'New Development Plan Layout','DP Maps','uploads/pdfs/DHOLERA New DP Plan-MAP.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (4,'TP 1A1 Final Naksha','Naksha','uploads/pdfs/TP 1A1_.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (5,'TP 1A2 Final Naksha','Naksha','uploads/pdfs/2___DHOLERA TP 1A2 FINAL.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (6,'TP 2B1 Naksha','Naksha','uploads/pdfs/TP.2B1 (1).pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (7,'TP 2B-1 Layout','Naksha','uploads/pdfs/3____2b-1.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (8,'TP 2B-2 Layout','Naksha','uploads/pdfs/4____2B-2.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (9,'TP 2B3 Layout','Naksha','uploads/pdfs/5____2B3.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (10,'TP 3B 2021','Naksha','uploads/pdfs/7_______3B_2021.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (11,'TP 4B1 2024','Naksha','uploads/pdfs/TP 4B1 2024.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (12,'TP 4B-1 After TR','Naksha','uploads/pdfs/12       TP 4B-1_Aftfter TR final-portrai.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (13,'TP 4B-2 Layout','Naksha','uploads/pdfs/10_TP-4B_2.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (14,'TP 5 O.P. F.P.','Naksha','uploads/pdfs/T.P. - 5 O.P. - F.P.  (1).pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (15,'TP 5A 2021','Naksha','uploads/pdfs/9_______5A_2021.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (16,'TP 5A After TR','Naksha','uploads/pdfs/14       TP5A ater TR final-Model.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (17,'TP 5B 2021','Naksha','uploads/pdfs/10_______5B_2021.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (18,'TP 6A 2021','Naksha','uploads/pdfs/11________6A_2021.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (19,'TP 3A Authority Paramarsh','PDFs','uploads/pdfs/08        TP3A Authority Paramarsh before Avord sudhara (authority paramars-Layout1.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (20,'TP 3C-1 CTP TR Paramarsh','PDFs','uploads/pdfs/10        TP 3C-1 CTP TR  Paramarsh-Layout1.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfDocuments" VALUES (21,'Infrastructure Update April 2026','PDFs','uploads/pdfs/14-04-2026   150238.pdf',1,'2026-05-04 18:50:22.345 +00:00','2026-05-04 18:50:22.345 +00:00');
INSERT INTO "PdfViews" VALUES (1,'2026-05-05 13:11:04.902 +00:00',0,'2026-05-05 13:11:04.902 +00:00','2026-05-05 13:11:04.902 +00:00',3,19);
INSERT INTO "PdfViews" VALUES (2,'2026-05-05 13:11:05.385 +00:00',0,'2026-05-05 13:11:05.385 +00:00','2026-05-05 13:11:05.385 +00:00',3,19);
INSERT INTO "PdfViews" VALUES (3,'2026-05-05 13:48:19.786 +00:00',0,'2026-05-05 13:48:19.786 +00:00','2026-05-05 13:48:19.786 +00:00',3,20);
INSERT INTO "PdfViews" VALUES (4,'2026-05-05 13:48:20.371 +00:00',0,'2026-05-05 13:48:20.371 +00:00','2026-05-05 13:48:20.371 +00:00',3,20);
INSERT INTO "PdfViews" VALUES (5,'2026-05-05 14:08:01.343 +00:00',0,'2026-05-05 14:08:01.343 +00:00','2026-05-05 14:08:01.343 +00:00',3,21);
INSERT INTO "PdfViews" VALUES (6,'2026-05-05 14:08:01.758 +00:00',0,'2026-05-05 14:08:01.758 +00:00','2026-05-05 14:08:01.758 +00:00',3,21);
INSERT INTO "Updates" VALUES (1,'Dholera International Airport Progress','The Dholera International Airport is progressing rapidly...','Infrastructure','/uploads/airport.jpg',1,'2026-05-04 18:50:22.736 +00:00','2026-05-04 18:50:22.736 +00:00');
INSERT INTO "Updates" VALUES (2,'Tata Semiconductor Plant Approval','Tata Group has secured approval for their massive semiconductor plant...','Industrial','/uploads/semiconductor.jpg',1,'2026-05-04 18:50:22.736 +00:00','2026-05-04 18:50:22.736 +00:00');
INSERT INTO "VisitorSessions" VALUES (1,'_tdblpbag9morjiwn1',5,'["/planning"]','Direct','Desktop','fp_mou4qc','::1','2026-05-04 18:50:53.268 +00:00','2026-05-04 18:50:54.195 +00:00');
INSERT INTO "VisitorSessions" VALUES (2,'_eja6galadmosm750s',1245,'["/planning"]','Direct','Desktop','fp_mou4qc','::1','2026-05-05 12:38:56.722 +00:00','2026-05-05 13:11:02.689 +00:00');
INSERT INTO "VisitorSessions" VALUES (3,'_nsow45r5fmosm7o1f',15,'["/terms-and-conditions"]','http://localhost:5174/planning','Desktop','fp_mou4qc','::1','2026-05-05 12:39:13.411 +00:00','2026-05-05 12:39:23.415 +00:00');
INSERT INTO "VisitorSessions" VALUES (4,'_8ybzx6m0gmospdmbw',25,'["/updates"]','Direct','Desktop','fp_mou4qc','::1','2026-05-05 14:08:25.107 +00:00','2026-05-05 14:08:45.090 +00:00');
COMMIT;
