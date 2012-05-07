USE [DBACentral]
GO
-- Add 1 row to [dbo].[ServerInventory_Environments]
SET IDENTITY_INSERT [dbo].[ServerInventory_Environments] ON
INSERT INTO [dbo].[ServerInventory_Environments] ([EnvironmentID], [EnvironmentName]) VALUES (7, 'OEC Production')
SET IDENTITY_INSERT [dbo].[ServerInventory_Environments] OFF


-- Reseed identity on [dbo].[ServerInventory_Environments]
DBCC CHECKIDENT('[dbo].[ServerInventory_Environments]', RESEED, 7)
GO