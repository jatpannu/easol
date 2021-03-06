/****** Object:  Database [easol_test]    Script Date: 9/24/2015 11:35:36 AM ******/
DROP DATABASE [easol_test]
GO
CREATE DATABASE [easol_test]
GO
USE [easol_test]
GO
ALTER DATABASE [easol_test] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [easol_test].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [easol_test] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [easol_test] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [easol_test] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [easol_test] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [easol_test] SET ARITHABORT OFF 
GO
ALTER DATABASE [easol_test] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [easol_test] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [easol_test] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [easol_test] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [easol_test] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [easol_test] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [easol_test] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [easol_test] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [easol_test] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [easol_test] SET  ENABLE_BROKER 
GO
ALTER DATABASE [easol_test] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [easol_test] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [easol_test] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [easol_test] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [easol_test] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [easol_test] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [easol_test] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [easol_test] SET RECOVERY FULL 
GO
ALTER DATABASE [easol_test] SET  MULTI_USER 
GO
ALTER DATABASE [easol_test] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [easol_test] SET DB_CHAINING OFF 
GO
USE [easol_test]
GO
/****** Object:  Schema [auth]    Script Date: 9/24/2015 11:35:41 AM ******/
CREATE SCHEMA [auth]
GO
/****** Object:  Schema [EASOL]    Script Date: 9/24/2015 11:35:42 AM ******/
CREATE SCHEMA [EASOL]
GO
/****** Object:  Schema [edfi]    Script Date: 9/24/2015 11:35:42 AM ******/
CREATE SCHEMA [edfi]
GO
/****** Object:  Schema [util]    Script Date: 9/24/2015 11:35:42 AM ******/
CREATE SCHEMA [util]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_diagramobjects]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE FUNCTION [dbo].[fn_diagramobjects]() 
	RETURNS int
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		declare @id_upgraddiagrams		int
		declare @id_sysdiagrams			int
		declare @id_helpdiagrams		int
		declare @id_helpdiagramdefinition	int
		declare @id_creatediagram	int
		declare @id_renamediagram	int
		declare @id_alterdiagram 	int 
		declare @id_dropdiagram		int
		declare @InstalledObjects	int

		select @InstalledObjects = 0

		select 	@id_upgraddiagrams = object_id(N'dbo.sp_upgraddiagrams'),
			@id_sysdiagrams = object_id(N'dbo.sysdiagrams'),
			@id_helpdiagrams = object_id(N'dbo.sp_helpdiagrams'),
			@id_helpdiagramdefinition = object_id(N'dbo.sp_helpdiagramdefinition'),
			@id_creatediagram = object_id(N'dbo.sp_creatediagram'),
			@id_renamediagram = object_id(N'dbo.sp_renamediagram'),
			@id_alterdiagram = object_id(N'dbo.sp_alterdiagram'), 
			@id_dropdiagram = object_id(N'dbo.sp_dropdiagram')

		if @id_upgraddiagrams is not null
			select @InstalledObjects = @InstalledObjects + 1
		if @id_sysdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 2
		if @id_helpdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 4
		if @id_helpdiagramdefinition is not null
			select @InstalledObjects = @InstalledObjects + 8
		if @id_creatediagram is not null
			select @InstalledObjects = @InstalledObjects + 16
		if @id_renamediagram is not null
			select @InstalledObjects = @InstalledObjects + 32
		if @id_alterdiagram  is not null
			select @InstalledObjects = @InstalledObjects + 64
		if @id_dropdiagram is not null
			select @InstalledObjects = @InstalledObjects + 128
		
		return @InstalledObjects 
	END
	
GO
/****** Object:  UserDefinedFunction [util].[Split]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [util].[Split](@String nvarchar(MAX), @Delimiter nvarchar(1)) 
RETURNS @Tokens table (Id int identity(1, 1), Token nvarchar(max)) 
AS
BEGIN
	WHILE(CHARINDEX(@Delimiter, @String) > 0)
	BEGIN 
		INSERT INTO @Tokens(Token) 
		SELECT LEFT(@String, ISNULL(NULLIF(CHARINDEX(@Delimiter, @String) -1, -1), LEN(@String)))
		
		SELECT @String = CASE WHEN CHARINDEX(@Delimiter, @String) > 0 THEN SUBSTRING(@String, CHARINDEX(@Delimiter, @String) + 1, LEN(@String)) ELSE '' END
	END

	INSERT INTO @Tokens(Token) 
	SELECT @String
	
	UPDATE @Tokens
	SET Token = LTRIM(RTRIM(Token))

	RETURN
END

--

GO
/****** Object:  Table [dbo].[DeleteEvent]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeleteEvent](
	[Id] [uniqueidentifier] NOT NULL,
	[DeletionDate] [datetime] NOT NULL,
	[TableName] [nvarchar](200) NOT NULL,
	[SchemaName] [nvarchar](200) NOT NULL
)

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [DeleteEvent_CX]    Script Date: 9/24/2015 11:35:42 AM ******/
CREATE CLUSTERED INDEX [DeleteEvent_CX] ON [dbo].[DeleteEvent]
(
	[TableName] ASC,
	[DeletionDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Table [dbo].[sysdiagrams]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[sysdiagrams](
	[name] [sysname] NOT NULL,
	[principal_id] [int] NOT NULL,
	[diagram_id] [int] IDENTITY(1,1) NOT NULL,
	[version] [int] NULL,
	[definition] [varbinary](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[diagram_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
 CONSTRAINT [UK_principal_name] UNIQUE NONCLUSTERED 
(
	[principal_id] ASC,
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[sysssislog]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sysssislog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[event] [sysname] NOT NULL,
	[computer] [nvarchar](128) NOT NULL,
	[operator] [nvarchar](128) NOT NULL,
	[source] [nvarchar](1024) NOT NULL,
	[sourceid] [uniqueidentifier] NOT NULL,
	[executionid] [uniqueidentifier] NOT NULL,
	[starttime] [datetime] NOT NULL,
	[endtime] [datetime] NOT NULL,
	[datacode] [int] NOT NULL,
	[databytes] [image] NULL,
	[message] [nvarchar](2048) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [dbo].[VersionLevel]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[VersionLevel](
	[ScriptSource] [varchar](256) NOT NULL,
	[ScriptType] [varchar](256) NOT NULL,
	[DatabaseType] [varchar](256) NOT NULL,
	[SubType] [varchar](1024) NULL,
	[VersionLevel] [int] NOT NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [ci_azure_fixup_dbo_VersionLevel]    Script Date: 9/24/2015 11:35:42 AM ******/
CREATE CLUSTERED INDEX [ci_azure_fixup_dbo_VersionLevel] ON [dbo].[VersionLevel]
(
	[VersionLevel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Table [EASOL].[DashboardConfiguration]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EASOL].[DashboardConfiguration](
	[DashboardConfigurationId] [int] IDENTITY(1,1) NOT NULL,
	[RoleTypeId] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[LeftChartReportId] [int] NULL,
	[RightChartReportId] [int] NULL,
	[BottomTableReportId] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[DashboardConfigurationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [EASOL].[Report]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [EASOL].[Report](
	[ReportId] [int] IDENTITY(1,1) NOT NULL,
	[ReportName] [nvarchar](255) NOT NULL,
	[ReportCategoryId] [int] NULL,
	[CommandText] [nvarchar](max) NOT NULL,
	[ReportDisplayId] [int] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[UpdatedBy] [int] NULL,
	[UpdatedOn] [datetime] NULL,
	[SchoolId] [int] NOT NULL,
	[LabelX] [varchar](50) NULL,
	[LabelY] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [EASOL].[ReportAccess]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EASOL].[ReportAccess](
	[ReportAccessId] [int] IDENTITY(1,1) NOT NULL,
	[ReportId] [int] NOT NULL,
	[RoleTypeId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReportAccessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [EASOL].[ReportCategory]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EASOL].[ReportCategory](
	[ReportCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[ReportCategoryName] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReportCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [EASOL].[ReportDisplay]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EASOL].[ReportDisplay](
	[ReportDisplayId] [int] IDENTITY(1,1) NOT NULL,
	[DisplayName] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReportDisplayId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [EASOL].[RoleType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EASOL].[RoleType](
	[RoleTypeId] [int] IDENTITY(1,1) NOT NULL,
	[RoleTypeName] [nvarchar](75) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [EASOL].[Schema]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EASOL].[Schema](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [nvarchar](255) NOT NULL,
	[TableType] [nvarchar](255) NOT NULL,
	[Display] [bit] NOT NULL,
	[Domain] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [EASOL].[SchoolConfiguration]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EASOL].[SchoolConfiguration](
	[EducationOrganizationId] [int] NOT NULL,
	[Key] [nvarchar](255) NOT NULL,
	[Value] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [EASOL].[StaffAuthentication]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EASOL].[StaffAuthentication](
	[StaffUSI] [int] NOT NULL,
	[Password] [nvarchar](40) NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[RoleId] [int] NULL,
	[Locked] [bit] NULL,
	[GoogleAuth] [bit] NULL
)

GO
/****** Object:  Table [edfi].[AcademicHonorCategoryType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AcademicHonorCategoryType](
	[AcademicHonorCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AcademicHonorCategoryType] PRIMARY KEY CLUSTERED 
(
	[AcademicHonorCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AcademicSubjectDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AcademicSubjectDescriptor](
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AcademicSubjectTypeId] [int] NOT NULL,
 CONSTRAINT [PK_AcademicSubjectDescriptor] PRIMARY KEY CLUSTERED 
(
	[AcademicSubjectDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AcademicSubjectType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AcademicSubjectType](
	[AcademicSubjectTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AcademicSubjectType] PRIMARY KEY CLUSTERED 
(
	[AcademicSubjectTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AcademicWeek]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AcademicWeek](
	[WeekIdentifier] [nvarchar](80) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[TotalInstructionalDays] [int] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AcademicWeek] PRIMARY KEY CLUSTERED 
(
	[WeekIdentifier] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AccommodationDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AccommodationDescriptor](
	[AccommodationDescriptorId] [int] NOT NULL,
	[AccommodationTypeId] [int] NULL,
 CONSTRAINT [PK_AccommodationDescriptor] PRIMARY KEY CLUSTERED 
(
	[AccommodationDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AccommodationType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AccommodationType](
	[AccommodationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[CodeValue] [nvarchar](50) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AccommodationType] PRIMARY KEY CLUSTERED 
(
	[AccommodationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Account]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Account](
	[EducationOrganizationId] [int] NOT NULL,
	[AccountNumber] [nvarchar](50) NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[AccountNumber] ASC,
	[FiscalYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AccountabilityRating]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AccountabilityRating](
	[EducationOrganizationId] [int] NOT NULL,
	[RatingTitle] [nvarchar](60) NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[Rating] [nvarchar](35) NOT NULL,
	[RatingDate] [date] NULL,
	[RatingOrganization] [nvarchar](35) NULL,
	[RatingProgram] [nvarchar](30) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AccountabilityRating] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[RatingTitle] ASC,
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AccountCode]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AccountCode](
	[EducationOrganizationId] [int] NOT NULL,
	[AccountNumber] [nvarchar](50) NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[AccountCodeDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AccountCode] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[AccountNumber] ASC,
	[FiscalYear] ASC,
	[AccountCodeDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AccountCodeDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AccountCodeDescriptor](
	[AccountCodeDescriptorId] [int] NOT NULL,
	[AccountCodeCategory] [nvarchar](20) NOT NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
 CONSTRAINT [PK_AccountCodeDescriptor] PRIMARY KEY CLUSTERED 
(
	[AccountCodeDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AchievementCategoryDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AchievementCategoryDescriptor](
	[AchievementCategoryDescriptorId] [int] NOT NULL,
	[AchievementCategoryTypeId] [int] NULL,
 CONSTRAINT [PK_AchievementCategoryDescriptor] PRIMARY KEY CLUSTERED 
(
	[AchievementCategoryDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AchievementCategoryType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AchievementCategoryType](
	[AchievementCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AchievementCategoryType] PRIMARY KEY CLUSTERED 
(
	[AchievementCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Actual]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Actual](
	[EducationOrganizationId] [int] NOT NULL,
	[AccountNumber] [nvarchar](50) NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[AmountToDate] [money] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Actual] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[AccountNumber] ASC,
	[FiscalYear] ASC,
	[AsOfDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AdditionalCreditType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AdditionalCreditType](
	[AdditionalCreditTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AdditionalCreditType] PRIMARY KEY CLUSTERED 
(
	[AdditionalCreditTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AddressType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AddressType](
	[AddressTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AddressType] PRIMARY KEY CLUSTERED 
(
	[AddressTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AdministrationEnvironmentType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AdministrationEnvironmentType](
	[AdministrationEnvironmentTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AdministrationEnvironmentType] PRIMARY KEY CLUSTERED 
(
	[AdministrationEnvironmentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AdministrativeFundingControlDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AdministrativeFundingControlDescriptor](
	[AdministrativeFundingControlDescriptorId] [int] NOT NULL,
	[AdministrativeFundingControlTypeId] [int] NULL,
 CONSTRAINT [PK_AdministrativeFundingControlDescriptor] PRIMARY KEY CLUSTERED 
(
	[AdministrativeFundingControlDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AdministrativeFundingControlType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AdministrativeFundingControlType](
	[AdministrativeFundingControlTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AdministrativeFundingControlType] PRIMARY KEY CLUSTERED 
(
	[AdministrativeFundingControlTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Assessment]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Assessment](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[AssessmentCategoryTypeId] [int] NULL,
	[LowestAssessedGradeLevelDescriptorId] [int] NULL,
	[AssessmentForm] [nvarchar](60) NULL,
	[RevisionDate] [date] NULL,
	[MaxRawScore] [int] NULL,
	[Nomenclature] [nvarchar](35) NULL,
	[AssessmentPeriodDescriptorId] [int] NULL,
	[AssessmentFamilyTitle] [nvarchar](60) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Assessment] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentCategoryType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentCategoryType](
	[AssessmentCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentCategoryType] PRIMARY KEY CLUSTERED 
(
	[AssessmentCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentContentStandard]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentContentStandard](
	[AssessmentVersion] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Title] [nvarchar](75) NOT NULL,
	[Version] [nvarchar](50) NULL,
	[URI] [nvarchar](255) NULL,
	[PublicationDate] [date] NULL,
	[PublicationYear] [smallint] NULL,
	[PublicationStatusTypeId] [int] NULL,
	[MandatingEducationOrganizationId] [int] NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentContentStandard] PRIMARY KEY CLUSTERED 
(
	[AssessmentVersion] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentContentStandardAuthor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentContentStandardAuthor](
	[AssessmentVersion] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Author] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentContentStandardAuthor] PRIMARY KEY CLUSTERED 
(
	[AssessmentVersion] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Author] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentFamily]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentFamily](
	[AssessmentFamilyTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NULL,
	[AssessedGradeLevelDescriptorId] [int] NULL,
	[Version] [int] NULL,
	[AssessmentCategoryTypeId] [int] NULL,
	[LowestAssessedGradeLevelDescriptorId] [int] NULL,
	[RevisionDate] [date] NULL,
	[Nomenclature] [nvarchar](35) NULL,
	[ParentAssessmentFamilyTitle] [nvarchar](60) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentFamily] PRIMARY KEY CLUSTERED 
(
	[AssessmentFamilyTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentFamilyAssessmentPeriod]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentFamilyAssessmentPeriod](
	[AssessmentFamilyTitle] [nvarchar](60) NOT NULL,
	[AssessmentPeriodDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentFamilyAssessmentPeriod] PRIMARY KEY CLUSTERED 
(
	[AssessmentFamilyTitle] ASC,
	[AssessmentPeriodDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentFamilyContentStandard]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentFamilyContentStandard](
	[AssessmentFamilyTitle] [nvarchar](60) NOT NULL,
	[Title] [nvarchar](75) NOT NULL,
	[Version] [nvarchar](50) NULL,
	[URI] [nvarchar](255) NULL,
	[PublicationDate] [date] NULL,
	[PublicationYear] [smallint] NULL,
	[PublicationStatusTypeId] [int] NULL,
	[MandatingEducationOrganizationId] [int] NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentFamilyContentStandard] PRIMARY KEY CLUSTERED 
(
	[AssessmentFamilyTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentFamilyContentStandardAuthor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentFamilyContentStandardAuthor](
	[AssessmentFamilyTitle] [nvarchar](60) NOT NULL,
	[Author] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentFamilyContentStandardAuthor] PRIMARY KEY CLUSTERED 
(
	[AssessmentFamilyTitle] ASC,
	[Author] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentFamilyIdentificationCode]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentFamilyIdentificationCode](
	[AssessmentFamilyTitle] [nvarchar](60) NOT NULL,
	[AssessmentIdentificationSystemTypeId] [int] NOT NULL,
	[AssigningOrganizationIdentificationCode] [nvarchar](60) NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentFamilyIdentificationCode] PRIMARY KEY CLUSTERED 
(
	[AssessmentFamilyTitle] ASC,
	[AssessmentIdentificationSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentFamilyLanguage]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentFamilyLanguage](
	[AssessmentFamilyTitle] [nvarchar](60) NOT NULL,
	[LanguageDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentFamiliyLanguages] PRIMARY KEY CLUSTERED 
(
	[AssessmentFamilyTitle] ASC,
	[LanguageDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentIdentificationCode]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentIdentificationCode](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[AssessmentIdentificationSystemTypeId] [int] NOT NULL,
	[AssigningOrganizationIdentificationCode] [nvarchar](60) NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentIdentificationCode] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[AssessmentIdentificationSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentIdentificationSystemType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentIdentificationSystemType](
	[AssessmentIdentificationSystemTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentIdentificationSystemType] PRIMARY KEY CLUSTERED 
(
	[AssessmentIdentificationSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentItem]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentItem](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[AssessmentItemCategoryTypeId] [int] NULL,
	[MaxRawScore] [int] NULL,
	[CorrectResponse] [nvarchar](20) NULL,
	[ExpectedTimeAssessed] [nvarchar](30) NULL,
	[Nomenclature] [nvarchar](35) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentItem] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentItemCategoryType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentItemCategoryType](
	[AssessmentItemCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ItemCategoryType] PRIMARY KEY CLUSTERED 
(
	[AssessmentItemCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentItemLearningStandard]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentItemLearningStandard](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentItemLearningStandard] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC,
	[LearningStandardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentItemResultType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentItemResultType](
	[AssessmentItemResultTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentItemResultType] PRIMARY KEY CLUSTERED 
(
	[AssessmentItemResultTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentLanguage]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentLanguage](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[LanguageDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentLanguages] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[LanguageDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentPerformanceLevel]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentPerformanceLevel](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[PerformanceLevelDescriptorId] [int] NOT NULL,
	[AssessmentReportingMethodTypeId] [int] NOT NULL,
	[MinimumScore] [nvarchar](35) NULL,
	[MaximumScore] [nvarchar](35) NULL,
	[ResultDatatypeTypeId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentPerformanceLevel] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[PerformanceLevelDescriptorId] ASC,
	[AssessmentReportingMethodTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentPeriodDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentPeriodDescriptor](
	[AssessmentPeriodDescriptorId] [int] NOT NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
 CONSTRAINT [PK_AssessmentPeriodDescriptor] PRIMARY KEY CLUSTERED 
(
	[AssessmentPeriodDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentProgram]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentProgram](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentProgram] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[EducationOrganizationId] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentReportingMethodType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentReportingMethodType](
	[AssessmentReportingMethodTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentReportingMethodType] PRIMARY KEY CLUSTERED 
(
	[AssessmentReportingMethodTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentScore]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentScore](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[AssessmentReportingMethodTypeId] [int] NOT NULL,
	[MinimumScore] [nvarchar](35) NULL,
	[MaximumScore] [nvarchar](35) NULL,
	[ResultDatatypeTypeId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentScore] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[AssessmentReportingMethodTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AssessmentSection]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AssessmentSection](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AssessmentSection] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AttendanceEventCategoryDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AttendanceEventCategoryDescriptor](
	[AttendanceEventCategoryDescriptorId] [int] NOT NULL,
	[AttendanceEventCategoryTypeId] [int] NOT NULL,
 CONSTRAINT [PK_AttendanceEventCategoryDescriptor] PRIMARY KEY CLUSTERED 
(
	[AttendanceEventCategoryDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[AttendanceEventCategoryType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[AttendanceEventCategoryType](
	[AttendanceEventCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AttendanceEventCategoryType] PRIMARY KEY CLUSTERED 
(
	[AttendanceEventCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[BehaviorDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[BehaviorDescriptor](
	[BehaviorDescriptorId] [int] NOT NULL,
	[BehaviorTypeId] [int] NULL,
 CONSTRAINT [PK_BehaviorDescriptor] PRIMARY KEY CLUSTERED 
(
	[BehaviorDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[BehaviorType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[BehaviorType](
	[BehaviorTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BehaviorType] PRIMARY KEY CLUSTERED 
(
	[BehaviorTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[BellSchedule]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[BellSchedule](
	[SchoolId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[BellScheduleName] [nvarchar](60) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BellSchedule] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[GradeLevelDescriptorId] ASC,
	[Date] ASC,
	[BellScheduleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[BellScheduleMeetingTime]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[BellScheduleMeetingTime](
	[SchoolId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[BellScheduleName] [nvarchar](60) NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[AlternateDayName] [nvarchar](20) NULL,
	[OfficialAttendancePeriod] [bit] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BellScheduleMeetingTime] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[GradeLevelDescriptorId] ASC,
	[Date] ASC,
	[BellScheduleName] ASC,
	[ClassPeriodName] ASC,
	[StartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Budget]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Budget](
	[EducationOrganizationId] [int] NOT NULL,
	[AccountNumber] [nvarchar](50) NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[Amount] [money] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Budget] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[AccountNumber] ASC,
	[FiscalYear] ASC,
	[AsOfDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CalendarDate]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CalendarDate](
	[EducationOrganizationId] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CalendarDate] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CalendarDateCalendarEvent]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CalendarDateCalendarEvent](
	[EducationOrganizationId] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[CalendarEventDescriptorId] [int] NOT NULL,
	[EventDuration] [decimal](3, 2) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CalendarDateCalendarEvent] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[Date] ASC,
	[CalendarEventDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CalendarEventDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CalendarEventDescriptor](
	[CalendarEventDescriptorId] [int] NOT NULL,
	[CalendarEventTypeId] [int] NOT NULL,
 CONSTRAINT [PK_CalendarEventDescriptor] PRIMARY KEY CLUSTERED 
(
	[CalendarEventDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CalendarEventType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CalendarEventType](
	[CalendarEventTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CalendarEventType] PRIMARY KEY CLUSTERED 
(
	[CalendarEventTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CareerPathwayType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CareerPathwayType](
	[CareerPathwayTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CareerPathwayType] PRIMARY KEY CLUSTERED 
(
	[CareerPathwayTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CharterStatusType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CharterStatusType](
	[CharterStatusTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CharterStatusType] PRIMARY KEY CLUSTERED 
(
	[CharterStatusTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CitizenshipStatusType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CitizenshipStatusType](
	[CitizenshipStatusTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CitizenshipStatusType] PRIMARY KEY CLUSTERED 
(
	[CitizenshipStatusTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ClassPeriod]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ClassPeriod](
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ClassPeriod] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[ClassPeriodName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ClassroomPositionDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ClassroomPositionDescriptor](
	[ClassroomPositionDescriptorId] [int] NOT NULL,
	[ClassroomPositionTypeId] [int] NULL,
 CONSTRAINT [PK_ClassroomPositionDescriptor] PRIMARY KEY CLUSTERED 
(
	[ClassroomPositionDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ClassroomPositionType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ClassroomPositionType](
	[ClassroomPositionTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ClassroomPositionType] PRIMARY KEY CLUSTERED 
(
	[ClassroomPositionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Cohort]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Cohort](
	[EducationOrganizationId] [int] NOT NULL,
	[CohortIdentifier] [nvarchar](20) NOT NULL,
	[CohortDescription] [nvarchar](1024) NULL,
	[CohortTypeId] [int] NOT NULL,
	[CohortScopeTypeId] [int] NULL,
	[AcademicSubjectDescriptorId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Cohort] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[CohortIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CohortProgram]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CohortProgram](
	[EducationOrganizationId] [int] NOT NULL,
	[CohortIdentifier] [nvarchar](20) NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CohortProgram] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[CohortIdentifier] ASC,
	[ProgramEducationOrganizationId] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CohortScopeType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CohortScopeType](
	[CohortScopeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CohortScopeType] PRIMARY KEY CLUSTERED 
(
	[CohortScopeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CohortType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CohortType](
	[CohortTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CohortType] PRIMARY KEY CLUSTERED 
(
	[CohortTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CohortYearType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CohortYearType](
	[CohortYearTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CohortYearType] PRIMARY KEY CLUSTERED 
(
	[CohortYearTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CompetencyLevelDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CompetencyLevelDescriptor](
	[CompetencyLevelDescriptorId] [int] NOT NULL,
	[PerformanceBaseConversionTypeId] [int] NULL,
 CONSTRAINT [PK_CompetencyLevelDescriptor] PRIMARY KEY CLUSTERED 
(
	[CompetencyLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CompetencyObjective]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CompetencyObjective](
	[Objective] [nvarchar](60) NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CompetencyObjectiveId] [nvarchar](60) NULL,
	[Description] [nvarchar](1024) NULL,
	[SuccessCriteria] [nvarchar](150) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CompetencyObjective] PRIMARY KEY CLUSTERED 
(
	[Objective] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ContentClassType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ContentClassType](
	[ContentClassTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ContentClassType] PRIMARY KEY CLUSTERED 
(
	[ContentClassTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ContinuationOfServicesReasonDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ContinuationOfServicesReasonDescriptor](
	[ContinuationOfServicesReasonDescriptorId] [int] NOT NULL,
	[ContinuationOfServicesReasonTypeId] [int] NOT NULL,
 CONSTRAINT [PK_ContinuationOfServicesReasonDescriptor] PRIMARY KEY CLUSTERED 
(
	[ContinuationOfServicesReasonDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ContinuationOfServicesReasonType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ContinuationOfServicesReasonType](
	[ContinuationOfServicesReasonTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ContinuationOfServicesReasonType] PRIMARY KEY CLUSTERED 
(
	[ContinuationOfServicesReasonTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ContractedStaff]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ContractedStaff](
	[StaffUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[AccountNumber] [nvarchar](50) NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[AmountToDate] [money] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ContractedStaff] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[EducationOrganizationId] ASC,
	[AccountNumber] ASC,
	[FiscalYear] ASC,
	[AsOfDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CostRateType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CostRateType](
	[CostRateTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CostRateType] PRIMARY KEY CLUSTERED 
(
	[CostRateTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CountryCodeType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CountryCodeType](
	[CountryCodeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CountryCodeType] PRIMARY KEY CLUSTERED 
(
	[CountryCodeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CountryType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CountryType](
	[CountryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CountryType] PRIMARY KEY CLUSTERED 
(
	[CountryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Course]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Course](
	[EducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[CourseTitle] [nvarchar](60) NOT NULL,
	[NumberOfParts] [int] NOT NULL,
	[AcademicSubjectDescriptorId] [int] NULL,
	[CourseDescription] [nvarchar](1024) NULL,
	[DateCourseAdopted] [date] NULL,
	[HighSchoolCourseRequirement] [bit] NULL,
	[CourseGPAApplicabilityTypeId] [int] NULL,
	[CourseDefinedByTypeId] [int] NULL,
	[MinimumAvailableCreditTypeId] [int] NULL,
	[MinimumAvailableCreditConversion] [decimal](9, 2) NULL,
	[MinimumAvailableCredit] [decimal](9, 2) NULL,
	[MaximumAvailableCreditTypeId] [int] NULL,
	[MaximumAvailableCreditConversion] [decimal](9, 2) NULL,
	[MaximumAvailableCredit] [decimal](9, 2) NULL,
	[CareerPathwayTypeId] [int] NULL,
	[TimeRequiredForCompletion] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[CourseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseAttemptResultType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseAttemptResultType](
	[CourseAttemptResultTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseAttemptResultType] PRIMARY KEY CLUSTERED 
(
	[CourseAttemptResultTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseCodeSystemType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseCodeSystemType](
	[CourseCodeSystemTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseCodeSystemType] PRIMARY KEY CLUSTERED 
(
	[CourseCodeSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseCompetencyLevel]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseCompetencyLevel](
	[EducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[CompetencyLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseCompetencyLevel] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[CourseCode] ASC,
	[CompetencyLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseDefinedByType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseDefinedByType](
	[CourseDefinedByTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseDefinedByType] PRIMARY KEY CLUSTERED 
(
	[CourseDefinedByTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseGPAApplicabilityType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseGPAApplicabilityType](
	[CourseGPAApplicabilityTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseGPAApplicabilityType] PRIMARY KEY CLUSTERED 
(
	[CourseGPAApplicabilityTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseGradeLevel]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseGradeLevel](
	[EducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseGradeLevel] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[CourseCode] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseIdentificationCode]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseIdentificationCode](
	[EducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[CourseCodeSystemTypeId] [int] NOT NULL,
	[AssigningOrganizationIdentificationCode] [nvarchar](60) NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseIdentificationCode] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[CourseCode] ASC,
	[CourseCodeSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseLearningObjective]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseLearningObjective](
	[EducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[Objective] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseLearningObjective] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[CourseCode] ASC,
	[Objective] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseLearningStandard]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseLearningStandard](
	[EducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseLearningStandard] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[CourseCode] ASC,
	[LearningStandardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseLevelCharacteristic]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseLevelCharacteristic](
	[EducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[CourseLevelCharacteristicTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseLevelCharacteristics] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[CourseCode] ASC,
	[CourseLevelCharacteristicTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseLevelCharacteristicType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseLevelCharacteristicType](
	[CourseLevelCharacteristicTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseLevelCharacteristicsType] PRIMARY KEY CLUSTERED 
(
	[CourseLevelCharacteristicTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseOffering]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseOffering](
	[SchoolId] [int] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[LocalCourseTitle] [nvarchar](60) NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[InstructionalTimePlanned] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseOffering] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[LocalCourseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseOfferingCurriculumUsed]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseOfferingCurriculumUsed](
	[SchoolId] [int] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[CurriculumUsedTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseOfferingCurriculumUsed] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[LocalCourseCode] ASC,
	[CurriculumUsedTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseRepeatCodeType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseRepeatCodeType](
	[CourseRepeatCodeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseRepeatCodeType] PRIMARY KEY CLUSTERED 
(
	[CourseRepeatCodeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseTranscript]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseTranscript](
	[StudentUSI] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[CourseEducationOrganizationId] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[CourseAttemptResultTypeId] [int] NOT NULL,
	[AttemptedCreditTypeId] [int] NULL,
	[AttemptedCreditConversion] [decimal](9, 2) NULL,
	[AttemptedCredit] [decimal](9, 2) NULL,
	[EarnedCreditTypeId] [int] NULL,
	[EarnedCreditConversion] [decimal](9, 2) NULL,
	[EarnedCredit] [decimal](9, 2) NOT NULL,
	[GradeLevelDescriptorId] [int] NULL,
	[MethodCreditEarnedTypeId] [int] NULL,
	[FinalLetterGradeEarned] [nvarchar](20) NULL,
	[FinalNumericGradeEarned] [int] NULL,
	[CourseRepeatCodeTypeId] [int] NULL,
	[SchoolId] [int] NULL,
	[CourseTitle] [nvarchar](60) NULL,
	[LocalCourseCode] [nvarchar](60) NULL,
	[LocalCourseTitle] [nvarchar](60) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseTranscript] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolYear] ASC,
	[TermTypeId] ASC,
	[CourseEducationOrganizationId] ASC,
	[EducationOrganizationId] ASC,
	[CourseCode] ASC,
	[CourseAttemptResultTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseTranscriptAdditionalCredit]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseTranscriptAdditionalCredit](
	[StudentUSI] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[CourseEducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[CourseAttemptResultTypeId] [int] NOT NULL,
	[AdditionalCreditTypeId] [int] NOT NULL,
	[Credit] [decimal](9, 2) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseTranscriptAdditionalCredit] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolYear] ASC,
	[TermTypeId] ASC,
	[CourseEducationOrganizationId] ASC,
	[CourseCode] ASC,
	[CourseAttemptResultTypeId] ASC,
	[AdditionalCreditTypeId] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CourseTranscriptExternalCourse]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CourseTranscriptExternalCourse](
	[StudentUSI] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[CourseEducationOrganizationId] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[CourseAttemptResultTypeId] [int] NOT NULL,
	[NameOfInstitution] [nvarchar](75) NOT NULL,
	[ExternalCourseCode] [nvarchar](60) NOT NULL,
	[ExternalCourseTitle] [nvarchar](60) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CourseTranscriptExternalCourse] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolYear] ASC,
	[TermTypeId] ASC,
	[CourseEducationOrganizationId] ASC,
	[EducationOrganizationId] ASC,
	[CourseCode] ASC,
	[CourseAttemptResultTypeId] ASC,
	[NameOfInstitution] ASC,
	[ExternalCourseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CredentialFieldDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CredentialFieldDescriptor](
	[CredentialFieldDescriptorId] [int] NOT NULL,
	[AcademicSubjectDescriptorId] [int] NULL,
 CONSTRAINT [PK_CredentialFieldDescriptor] PRIMARY KEY CLUSTERED 
(
	[CredentialFieldDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CredentialType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CredentialType](
	[CredentialTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CredentialType] PRIMARY KEY CLUSTERED 
(
	[CredentialTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CreditType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CreditType](
	[CreditTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CreditType] PRIMARY KEY CLUSTERED 
(
	[CreditTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[CurriculumUsedType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[CurriculumUsedType](
	[CurriculumUsedTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CurriculumUsedType] PRIMARY KEY CLUSTERED 
(
	[CurriculumUsedTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DeliveryMethodType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DeliveryMethodType](
	[DeliveryMethodTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DeliveryMethodType] PRIMARY KEY CLUSTERED 
(
	[DeliveryMethodTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Descriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Descriptor](
	[DescriptorId] [int] IDENTITY(1,1) NOT NULL,
	[Namespace] [nvarchar](255) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](75) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[PriorDescriptorId] [int] NULL,
	[EffectiveBeginDate] [date] NULL,
	[EffectiveEndDate] [date] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Descriptor] PRIMARY KEY CLUSTERED 
(
	[DescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
 CONSTRAINT [AK_Descriptor] UNIQUE NONCLUSTERED 
(
	[Namespace] ASC,
	[CodeValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DiagnosisDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DiagnosisDescriptor](
	[DiagnosisDescriptorId] [int] NOT NULL,
	[DiagnosisTypeId] [int] NULL,
 CONSTRAINT [PK_DiagnosisDescriptor] PRIMARY KEY CLUSTERED 
(
	[DiagnosisDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DiagnosisType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DiagnosisType](
	[DiagnosisTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DiagnosisType] PRIMARY KEY CLUSTERED 
(
	[DiagnosisTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DiplomaLevelType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DiplomaLevelType](
	[DiplomaLevelTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DiplomaLevelType] PRIMARY KEY CLUSTERED 
(
	[DiplomaLevelTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DiplomaType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DiplomaType](
	[DiplomaTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DiplomaType] PRIMARY KEY CLUSTERED 
(
	[DiplomaTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisabilityCategoryType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisabilityCategoryType](
	[DisabilityCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisabilityCategoryType] PRIMARY KEY CLUSTERED 
(
	[DisabilityCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisabilityDescriptor]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisabilityDescriptor](
	[DisabilityDescriptorId] [int] NOT NULL,
	[DisabilityCategoryTypeId] [int] NOT NULL,
	[DisabilityTypeId] [int] NULL,
 CONSTRAINT [PK_DisabilityDescriptor] PRIMARY KEY CLUSTERED 
(
	[DisabilityDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisabilityType]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisabilityType](
	[DisabilityTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisabilityType] PRIMARY KEY CLUSTERED 
(
	[DisabilityTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineAction]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineAction](
	[StudentUSI] [int] NOT NULL,
	[DisciplineActionIdentifier] [nvarchar](20) NOT NULL,
	[DisciplineDate] [date] NOT NULL,
	[DisciplineActionLength] [int] NULL,
	[ActualDisciplineActionLength] [int] NULL,
	[DisciplineActionLengthDifferenceReasonTypeId] [int] NULL,
	[ResponsibilitySchoolId] [int] NOT NULL,
	[AssignmentSchoolId] [int] NULL,
	[RelatedToZeroTolerancePolicy] [bit] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisciplineAction] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[DisciplineActionIdentifier] ASC,
	[DisciplineDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineActionDiscipline]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineActionDiscipline](
	[StudentUSI] [int] NOT NULL,
	[DisciplineActionIdentifier] [nvarchar](20) NOT NULL,
	[DisciplineDate] [date] NOT NULL,
	[DisciplineDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisciplineActionDiscipline] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[DisciplineActionIdentifier] ASC,
	[DisciplineDate] ASC,
	[DisciplineDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineActionDisciplineIncident]    Script Date: 9/24/2015 11:35:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineActionDisciplineIncident](
	[StudentUSI] [int] NOT NULL,
	[DisciplineActionIdentifier] [nvarchar](20) NOT NULL,
	[DisciplineDate] [date] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[IncidentIdentifier] [nvarchar](20) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisciplineActionDisciplineIncident] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[DisciplineActionIdentifier] ASC,
	[DisciplineDate] ASC,
	[SchoolId] ASC,
	[IncidentIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineActionLengthDifferenceReasonType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineActionLengthDifferenceReasonType](
	[DisciplineActionLengthDifferenceReasonTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisciplineActionLengthDifferenceReasonType] PRIMARY KEY CLUSTERED 
(
	[DisciplineActionLengthDifferenceReasonTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineActionStaff]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineActionStaff](
	[StudentUSI] [int] NOT NULL,
	[DisciplineActionIdentifier] [nvarchar](20) NOT NULL,
	[DisciplineDate] [date] NOT NULL,
	[StaffUSI] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisciplineActionStaff] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[DisciplineActionIdentifier] ASC,
	[DisciplineDate] ASC,
	[StaffUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineDescriptor](
	[DisciplineDescriptorId] [int] NOT NULL,
	[DisciplineTypeId] [int] NULL,
 CONSTRAINT [PK_DisciplineDescriptor] PRIMARY KEY CLUSTERED 
(
	[DisciplineDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineIncident]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineIncident](
	[SchoolId] [int] NOT NULL,
	[IncidentIdentifier] [nvarchar](20) NOT NULL,
	[IncidentDate] [date] NOT NULL,
	[IncidentTime] [time](7) NULL,
	[IncidentLocationTypeId] [int] NULL,
	[ReporterDescriptionDescriptorId] [int] NULL,
	[ReporterName] [nvarchar](75) NULL,
	[ReportedToLawEnforcement] [bit] NULL,
	[CaseNumber] [nvarchar](20) NULL,
	[StaffUSI] [int] NULL,
	[IncidentDescription] [nvarchar](1024) NULL,
	[IncidentCost] [money] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisciplineIncident] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[IncidentIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineIncidentBehavior]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineIncidentBehavior](
	[SchoolId] [int] NOT NULL,
	[IncidentIdentifier] [nvarchar](20) NOT NULL,
	[BehaviorDescriptorId] [int] NOT NULL,
	[BehaviorDetailedDescription] [nvarchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisciplineIncidentBehavior] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[IncidentIdentifier] ASC,
	[BehaviorDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineIncidentWeapon]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineIncidentWeapon](
	[SchoolId] [int] NOT NULL,
	[IncidentIdentifier] [nvarchar](20) NOT NULL,
	[WeaponDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisciplineIncidentWeapons] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[IncidentIdentifier] ASC,
	[WeaponDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[DisciplineType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[DisciplineType](
	[DisciplineTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[CodeValue] [nvarchar](50) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DisciplineType] PRIMARY KEY CLUSTERED 
(
	[DisciplineTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EdFiException]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EdFiException](
	[EdFiExceptionId] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [nvarchar](255) NULL,
	[ColumnNameList] [nvarchar](4000) NULL,
	[ColumnValueList] [nvarchar](4000) NULL,
	[ErrorMessage] [nvarchar](4000) NULL,
	[IdentifierCondition] [nvarchar](4000) NULL,
	[LookupCondition] [nvarchar](4000) NULL,
	[ExceptionLevel] [nvarchar](20) NULL,
	[StartTime] [datetime] NULL,
	[PackageName] [nvarchar](255) NULL,
	[TaskName] [nvarchar](255) NULL,
	[ComponentName] [nvarchar](255) NULL,
	[ErrorCode] [int] NULL,
	[ErrorDescription] [nvarchar](1000) NULL,
	[ErrorColumn] [int] NULL,
	[ErrorColumnName] [nvarchar](255) NULL,
 CONSTRAINT [PK_EdFiException] PRIMARY KEY CLUSTERED 
(
	[EdFiExceptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationalEnvironmentType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationalEnvironmentType](
	[EducationalEnvironmentTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationalEnvironmentType] PRIMARY KEY CLUSTERED 
(
	[EducationalEnvironmentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationContent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationContent](
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[LearningResourceMetadataURI] [nvarchar](255) NULL,
	[ShortDescription] [nvarchar](75) NULL,
	[Description] [nvarchar](1024) NULL,
	[AdditionalAuthorsIndicator] [bit] NULL,
	[Publisher] [nvarchar](50) NULL,
	[TimeRequired] [nvarchar](30) NULL,
	[InteractivityStyleTypeId] [int] NULL,
	[ContentClassTypeId] [int] NULL,
	[UseRightsURL] [nvarchar](255) NULL,
	[PublicationDate] [date] NULL,
	[PublicationYear] [smallint] NULL,
	[LearningStandardId] [nvarchar](60) NULL,
	[Version] [nvarchar](10) NULL,
	[Cost] [money] NULL,
	[CostRateTypeId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationContent] PRIMARY KEY CLUSTERED 
(
	[ContentIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationContentAppropriateGradeLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationContentAppropriateGradeLevel](
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationContentAppropriateGradeLevel] PRIMARY KEY CLUSTERED 
(
	[ContentIdentifier] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationContentAppropriateSex]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationContentAppropriateSex](
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[SexTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationContentAppropriateSex] PRIMARY KEY CLUSTERED 
(
	[ContentIdentifier] ASC,
	[SexTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationContentAuthor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationContentAuthor](
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[Author] [nvarchar](225) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationContentAuthor] PRIMARY KEY CLUSTERED 
(
	[ContentIdentifier] ASC,
	[Author] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationContentDerivativeSourceEducationContent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationContentDerivativeSourceEducationContent](
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[DerivativeSourceContentIdentifier] [nvarchar](225) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationContentDerivativeSourceEducationContent] PRIMARY KEY CLUSTERED 
(
	[ContentIdentifier] ASC,
	[DerivativeSourceContentIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationContentDerivativeSourceLearningResourceMetadataURI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationContentDerivativeSourceLearningResourceMetadataURI](
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[LearningResourceMetadataURI] [nvarchar](225) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationContentDerivativeSourceLearningResourceMetadataURI] PRIMARY KEY CLUSTERED 
(
	[ContentIdentifier] ASC,
	[LearningResourceMetadataURI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationContentDerivativeSourceURI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationContentDerivativeSourceURI](
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[URI] [nvarchar](225) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationContentDerivativeSourceURI] PRIMARY KEY CLUSTERED 
(
	[ContentIdentifier] ASC,
	[URI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationContentLanguage]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationContentLanguage](
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[LanguageDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationContentLanguage] PRIMARY KEY CLUSTERED 
(
	[ContentIdentifier] ASC,
	[LanguageDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganization]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganization](
	[EducationOrganizationId] [int] NOT NULL,
	[StateOrganizationId] [nvarchar](60) NOT NULL,
	[NameOfInstitution] [nvarchar](75) NOT NULL,
	[ShortNameOfInstitution] [nvarchar](75) NULL,
	[WebSite] [nvarchar](255) NULL,
	[OperationalStatusTypeId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganization] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationAddress]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationAddress](
	[EducationOrganizationId] [int] NOT NULL,
	[AddressTypeId] [int] NOT NULL,
	[StreetNumberName] [nvarchar](150) NOT NULL,
	[ApartmentRoomSuiteNumber] [nvarchar](50) NULL,
	[BuildingSiteNumber] [nvarchar](20) NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateAbbreviationTypeId] [int] NOT NULL,
	[PostalCode] [nvarchar](17) NOT NULL,
	[NameOfCounty] [nvarchar](30) NULL,
	[CountyFIPSCode] [nvarchar](5) NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationAddress] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[AddressTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationCategory]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationCategory](
	[EducationOrganizationId] [int] NOT NULL,
	[EducationOrganizationCategoryTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationCategory] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[EducationOrganizationCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationCategoryType](
	[EducationOrganizationCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[CodeValue] [nvarchar](75) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationCategoryType] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationIdentificationCode]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationIdentificationCode](
	[EducationOrganizationId] [int] NOT NULL,
	[EducationOrganizationIdentificationSystemTypeId] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationIdentificationCode] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[EducationOrganizationIdentificationSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationIdentificationSystemType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationIdentificationSystemType](
	[EducationOrganizationIdentificationSystemTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrgIdentificationSystemType] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationIdentificationSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationInstitutionTelephone]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationInstitutionTelephone](
	[EducationOrganizationId] [int] NOT NULL,
	[InstitutionTelephoneNumberTypeId] [int] NOT NULL,
	[TelephoneNumber] [nvarchar](24) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationInstitutionTelephone] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[InstitutionTelephoneNumberTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationInternationalAddress]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationInternationalAddress](
	[EducationOrganizationId] [int] NOT NULL,
	[AddressTypeId] [int] NOT NULL,
	[AddressLine1] [nvarchar](150) NOT NULL,
	[AddressLine2] [nvarchar](150) NULL,
	[AddressLine3] [nvarchar](150) NULL,
	[AddressLine4] [nvarchar](150) NULL,
	[CountryTypeId] [int] NOT NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationInternationalAddress] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[AddressTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationInterventionPrescriptionAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationInterventionPrescriptionAssociation](
	[EducationOrganizationId] [int] NOT NULL,
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[InterventionPrescriptionEducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationInterventionPrescriptionAssociation_1] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[InterventionPrescriptionIdentificationCode] ASC,
	[InterventionPrescriptionEducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationNetwork]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationNetwork](
	[EducationOrganizationNetworkId] [int] NOT NULL,
	[NetworkPurposeTypeId] [int] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationNetwork] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationNetworkId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationNetworkAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationNetworkAssociation](
	[MemberEducationOrganizationId] [int] NOT NULL,
	[EducationOrganizationNetworkId] [int] NOT NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationNetworkAssociation] PRIMARY KEY CLUSTERED 
(
	[MemberEducationOrganizationId] ASC,
	[EducationOrganizationNetworkId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationOrganizationPeerAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationOrganizationPeerAssociation](
	[EducationOrganizationId] [int] NOT NULL,
	[PeerEducationOrganizationId] [int] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationOrganizationPeerAssociation] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[PeerEducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationPlanType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationPlanType](
	[EducationPlanTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EducationPlansType] PRIMARY KEY CLUSTERED 
(
	[EducationPlanTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EducationServiceCenter]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EducationServiceCenter](
	[EducationServiceCenterId] [int] NOT NULL,
	[StateEducationAgencyId] [int] NULL,
 CONSTRAINT [PK_EducationServiceCenter] PRIMARY KEY CLUSTERED 
(
	[EducationServiceCenterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ElectronicMailType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ElectronicMailType](
	[ElectronicMailTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ElectronicMailType] PRIMARY KEY CLUSTERED 
(
	[ElectronicMailTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EmploymentStatusDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EmploymentStatusDescriptor](
	[EmploymentStatusDescriptorId] [int] NOT NULL,
	[EmploymentStatusTypeId] [int] NOT NULL,
 CONSTRAINT [PK_EmploymentStatusDescriptor] PRIMARY KEY CLUSTERED 
(
	[EmploymentStatusDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EmploymentStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EmploymentStatusType](
	[EmploymentStatusTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EmploymentStatusType] PRIMARY KEY CLUSTERED 
(
	[EmploymentStatusTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EntryGradeLevelReasonType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EntryGradeLevelReasonType](
	[EntryGradeLevelReasonTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EntryGradeLevelReasonType] PRIMARY KEY CLUSTERED 
(
	[EntryGradeLevelReasonTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EntryType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EntryType](
	[EntryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EntryType] PRIMARY KEY CLUSTERED 
(
	[EntryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EntryTypeDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EntryTypeDescriptor](
	[EntryTypeDescriptorId] [int] NOT NULL,
	[EntryTypeId] [int] NULL,
 CONSTRAINT [PK_EntryTypeDescriptor] PRIMARY KEY CLUSTERED 
(
	[EntryTypeDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[EventCircumstanceType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[EventCircumstanceType](
	[EventCircumstanceTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_EventCircumstanceType] PRIMARY KEY CLUSTERED 
(
	[EventCircumstanceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ExitWithdrawType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ExitWithdrawType](
	[ExitWithdrawTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ExitWithdrawType] PRIMARY KEY CLUSTERED 
(
	[ExitWithdrawTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ExitWithdrawTypeDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ExitWithdrawTypeDescriptor](
	[ExitWithdrawTypeDescriptorId] [int] NOT NULL,
	[ExitWithdrawTypeId] [int] NULL,
 CONSTRAINT [PK_ExitWithdrawTypeDescriptor] PRIMARY KEY CLUSTERED 
(
	[ExitWithdrawTypeDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[FeederSchoolAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[FeederSchoolAssociation](
	[SchoolId] [int] NOT NULL,
	[FeederSchoolId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[FeederRelationshipDescription] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_FeederSchoolAssociation] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[FeederSchoolId] ASC,
	[BeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Grade]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Grade](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[GradingPeriodBeginDate] [date] NOT NULL,
	[GradingPeriodEducationOrganizationId] [int] NOT NULL,
	[LetterGradeEarned] [nvarchar](20) NULL,
	[NumericGradeEarned] [int] NULL,
	[DiagnosticStatement] [nvarchar](1024) NULL,
	[GradeTypeId] [int] NOT NULL,
	[PerformanceBaseConversionTypeId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Grade] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[BeginDate] ASC,
	[GradingPeriodDescriptorId] ASC,
	[GradingPeriodBeginDate] ASC,
	[GradingPeriodEducationOrganizationId] ASC,
	[GradeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradebookEntry]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradebookEntry](
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[GradebookEntryTitle] [nvarchar](60) NOT NULL,
	[DateAssigned] [date] NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[GradingPeriodDescriptorId] [int] NULL,
	[BeginDate] [date] NULL,
	[GradebookEntryTypeId] [int] NULL,
	[EducationOrganizationId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GradebookEntry] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[GradebookEntryTitle] ASC,
	[DateAssigned] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradebookEntryLearningObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradebookEntryLearningObjective](
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[GradebookEntryTitle] [nvarchar](60) NOT NULL,
	[DateAssigned] [date] NOT NULL,
	[Objective] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GradebookEntryLearningObjective] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[GradebookEntryTitle] ASC,
	[DateAssigned] ASC,
	[Objective] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradebookEntryLearningStandard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradebookEntryLearningStandard](
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[GradebookEntryTitle] [nvarchar](60) NOT NULL,
	[DateAssigned] [date] NOT NULL,
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GradebookEntryLearningStandard] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[GradebookEntryTitle] ASC,
	[DateAssigned] ASC,
	[LearningStandardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradebookEntryType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradebookEntryType](
	[GradebookEntryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GradebookEntryType] PRIMARY KEY CLUSTERED 
(
	[GradebookEntryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradeLevelDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradeLevelDescriptor](
	[GradeLevelDescriptorId] [int] NOT NULL,
	[GradeLevelTypeId] [int] NOT NULL,
 CONSTRAINT [PK_GradeLevelDescriptor] PRIMARY KEY CLUSTERED 
(
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradeLevelType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradeLevelType](
	[GradeLevelTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GradeLevelType] PRIMARY KEY CLUSTERED 
(
	[GradeLevelTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradeType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradeType](
	[GradeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GradeType] PRIMARY KEY CLUSTERED 
(
	[GradeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradingPeriod]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradingPeriod](
	[EducationOrganizationId] [int] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[TotalInstructionalDays] [int] NOT NULL,
	[PeriodSequence] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GradingPeriod] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[GradingPeriodDescriptorId] ASC,
	[BeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradingPeriodDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradingPeriodDescriptor](
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[GradingPeriodTypeId] [int] NOT NULL,
 CONSTRAINT [PK_GradingPeriodDescriptor] PRIMARY KEY CLUSTERED 
(
	[GradingPeriodDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GradingPeriodType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GradingPeriodType](
	[GradingPeriodTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[PeriodSequence] [int] NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GradingPeriodType] PRIMARY KEY CLUSTERED 
(
	[GradingPeriodTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GraduationPlan]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GraduationPlan](
	[EducationOrganizationId] [int] NOT NULL,
	[IndividualPlan] [bit] NULL,
	[TotalRequiredCredit] [decimal](9, 2) NOT NULL,
	[TotalRequiredCreditTypeId] [int] NULL,
	[TotalRequiredCreditConversion] [decimal](9, 2) NULL,
	[GraduationPlanTypeDescriptorId] [int] NOT NULL,
	[GraduationSchoolYear] [smallint] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GraduationPlan] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[GraduationPlanTypeDescriptorId] ASC,
	[GraduationSchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GraduationPlanCreditsByCourse]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GraduationPlanCreditsByCourse](
	[EducationOrganizationId] [int] NOT NULL,
	[Credit] [decimal](9, 2) NOT NULL,
	[CreditTypeId] [int] NULL,
	[CreditConversion] [decimal](9, 2) NULL,
	[GradeLevelDescriptorId] [int] NULL,
	[GraduationPlanTypeDescriptorId] [int] NOT NULL,
	[GraduationSchoolYear] [smallint] NOT NULL,
	[CourseSetName] [nvarchar](120) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GraduationPlanCreditsByCourse] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[GraduationPlanTypeDescriptorId] ASC,
	[GraduationSchoolYear] ASC,
	[CourseSetName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GraduationPlanCreditsByCourseCourse]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GraduationPlanCreditsByCourseCourse](
	[EducationOrganizationId] [int] NOT NULL,
	[GraduationPlanTypeDescriptorId] [int] NOT NULL,
	[GraduationSchoolYear] [smallint] NOT NULL,
	[CourseSetName] [nvarchar](120) NOT NULL,
	[CourseEducationOrganizationId] [int] NOT NULL,
	[CourseCode] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GraduationPlanCreditsByCourseCourse] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[GraduationPlanTypeDescriptorId] ASC,
	[GraduationSchoolYear] ASC,
	[CourseSetName] ASC,
	[CourseEducationOrganizationId] ASC,
	[CourseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GraduationPlanCreditsBySubject]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GraduationPlanCreditsBySubject](
	[EducationOrganizationId] [int] NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[Credit] [decimal](9, 2) NOT NULL,
	[CreditTypeId] [int] NULL,
	[CreditConversion] [decimal](9, 2) NULL,
	[GraduationPlanTypeDescriptorId] [int] NOT NULL,
	[GraduationSchoolYear] [smallint] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GraduationPlanCreditsBySubject] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[GraduationPlanTypeDescriptorId] ASC,
	[GraduationSchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GraduationPlanType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GraduationPlanType](
	[GraduationPlanTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GraduationPlanType] PRIMARY KEY CLUSTERED 
(
	[GraduationPlanTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GraduationPlanTypeDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GraduationPlanTypeDescriptor](
	[GraduationPlanTypeDescriptorId] [int] NOT NULL,
	[GraduationPlanTypeId] [int] NULL,
 CONSTRAINT [PK_GraduationPlanTypeDescriptor] PRIMARY KEY CLUSTERED 
(
	[GraduationPlanTypeDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[GunFreeSchoolsActReportingStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[GunFreeSchoolsActReportingStatusType](
	[GunFreeSchoolsActReportingStatusTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GunFreeSchoolsActReportingStatusType] PRIMARY KEY CLUSTERED 
(
	[GunFreeSchoolsActReportingStatusTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[IdentificationDocumentUseType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[IdentificationDocumentUseType](
	[IdentificationDocumentUseTypeId] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_IdentificationDocumentUseType] PRIMARY KEY CLUSTERED 
(
	[IdentificationDocumentUseTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[IncidentLocationType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[IncidentLocationType](
	[IncidentLocationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_IncidentLocationType] PRIMARY KEY CLUSTERED 
(
	[IncidentLocationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InstitutionTelephoneNumberType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InstitutionTelephoneNumberType](
	[InstitutionTelephoneNumberTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InstitutionTelephoneNumberType] PRIMARY KEY CLUSTERED 
(
	[InstitutionTelephoneNumberTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[IntegratedTechnologyStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[IntegratedTechnologyStatusType](
	[IntegratedTechnologyStatusTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_IntegratedTechnologyStatusType] PRIMARY KEY CLUSTERED 
(
	[IntegratedTechnologyStatusTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InteractivityStyleType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InteractivityStyleType](
	[InteractivityStyleTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InteractivityStyleType] PRIMARY KEY CLUSTERED 
(
	[InteractivityStyleTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InternetAccessType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InternetAccessType](
	[InternetAccessTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[CodeValue] [nvarchar](50) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InternetAccessType] PRIMARY KEY CLUSTERED 
(
	[InternetAccessTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Intervention]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Intervention](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[InterventionClassTypeId] [int] NOT NULL,
	[DeliveryMethodTypeId] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[ShortDescription] [nvarchar](75) NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Intervention] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionAppropriateGradeLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionAppropriateGradeLevel](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionAppropriateGradeLevel] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionAppropriateSex]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionAppropriateSex](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[SexTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionAppropriateSex] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[SexTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionClassType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionClassType](
	[InterventionClassTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionClassType] PRIMARY KEY CLUSTERED 
(
	[InterventionClassTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionDiagnosis]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionDiagnosis](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[DiagnosisDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionDiagnosis] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[DiagnosisDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionEducationContent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionEducationContent](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionEducationContent] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[ContentIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionEffectivenessRatingType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionEffectivenessRatingType](
	[InterventionEffectivenessRatingTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionEffectivenessRatingType] PRIMARY KEY CLUSTERED 
(
	[InterventionEffectivenessRatingTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionInterventionPrescription]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionInterventionPrescription](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[InterventionPrescriptionEducationOrganizationId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionInterventionPrescription] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[InterventionPrescriptionIdentificationCode] ASC,
	[InterventionPrescriptionEducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionLearningResourceMetadataURI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionLearningResourceMetadataURI](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[LearningResourceMetadataURI] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionLearningResourceMetadataURI] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[LearningResourceMetadataURI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionMeetingTime]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionMeetingTime](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[AlternateDayName] [nvarchar](20) NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[OfficialAttendancePeriod] [bit] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionMeetingTime] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[SchoolId] ASC,
	[ClassPeriodName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionPopulationServed]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionPopulationServed](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[PopulationServedTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionPopulationServed] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[PopulationServedTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionPrescription]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionPrescription](
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[InterventionClassTypeId] [int] NOT NULL,
	[DeliveryMethodTypeId] [int] NOT NULL,
	[ShortDescription] [nvarchar](75) NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionPrescription] PRIMARY KEY CLUSTERED 
(
	[InterventionPrescriptionIdentificationCode] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionPrescriptionAppropriateGradeLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionPrescriptionAppropriateGradeLevel](
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionPrescriptionAppropriateGradeLevel] PRIMARY KEY CLUSTERED 
(
	[InterventionPrescriptionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionPrescriptionAppropriateSex]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionPrescriptionAppropriateSex](
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[SexTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionPrescriptionAppropriateSex] PRIMARY KEY CLUSTERED 
(
	[InterventionPrescriptionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[SexTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionPrescriptionDiagnosis]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionPrescriptionDiagnosis](
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[DiagnosisDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionPrescriptionDiagnosis] PRIMARY KEY CLUSTERED 
(
	[InterventionPrescriptionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[DiagnosisDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionPrescriptionEducationContent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionPrescriptionEducationContent](
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionPrescriptionEducationContent] PRIMARY KEY CLUSTERED 
(
	[InterventionPrescriptionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[ContentIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionPrescriptionLearningResourceMetadataURI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionPrescriptionLearningResourceMetadataURI](
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[LearningResourceMetadataURI] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionPrescriptionLearningResourceMetadataURI] PRIMARY KEY CLUSTERED 
(
	[InterventionPrescriptionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[LearningResourceMetadataURI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionPrescriptionPopulationServed]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionPrescriptionPopulationServed](
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[PopulationServedTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionPrescriptionPopulationServed] PRIMARY KEY CLUSTERED 
(
	[InterventionPrescriptionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[PopulationServedTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionPrescriptionURI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionPrescriptionURI](
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[URI] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionPrescriptionURI] PRIMARY KEY CLUSTERED 
(
	[InterventionPrescriptionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[URI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStaff]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStaff](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[StaffUSI] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStaff] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[StaffUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStudy]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStudy](
	[InterventionStudyIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[InterventionPrescriptionIdentificationCode] [nvarchar](60) NOT NULL,
	[InterventionPrescriptionEducationOrganizationId] [int] NOT NULL,
	[Participants] [int] NOT NULL,
	[DeliveryMethodTypeId] [int] NOT NULL,
	[InterventionClassTypeId] [int] NOT NULL,
	[ShortDescription] [nvarchar](75) NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStudy] PRIMARY KEY CLUSTERED 
(
	[InterventionStudyIdentificationCode] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStudyAppropriateGradeLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStudyAppropriateGradeLevel](
	[InterventionStudyIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStudyAppropriateGradeLevel] PRIMARY KEY CLUSTERED 
(
	[InterventionStudyIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStudyAppropriateSex]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStudyAppropriateSex](
	[InterventionStudyIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[SexTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStudyAppropriateSex] PRIMARY KEY CLUSTERED 
(
	[InterventionStudyIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[SexTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStudyEducationContent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStudyEducationContent](
	[InterventionStudyIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[ContentIdentifier] [nvarchar](225) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStudyEducationContent] PRIMARY KEY CLUSTERED 
(
	[InterventionStudyIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[ContentIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStudyInterventionEffectiveness]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStudyInterventionEffectiveness](
	[InterventionStudyIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[DiagnosisDescriptorId] [int] NOT NULL,
	[PopulationServedTypeId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[ImprovementIndex] [int] NULL,
	[InterventionEffectivenessRatingTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStudyInterventionEffectiveness] PRIMARY KEY CLUSTERED 
(
	[InterventionStudyIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[DiagnosisDescriptorId] ASC,
	[PopulationServedTypeId] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStudyLearningResourceMetadataURI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStudyLearningResourceMetadataURI](
	[InterventionStudyIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[LearningResourceMetadataURI] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStudyLearningResourceMetadataURI] PRIMARY KEY CLUSTERED 
(
	[InterventionStudyIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[LearningResourceMetadataURI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStudyPopulationServed]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStudyPopulationServed](
	[InterventionStudyIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[PopulationServedTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStudyPopulationServed] PRIMARY KEY CLUSTERED 
(
	[InterventionStudyIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[PopulationServedTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStudyStateAbbreviation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStudyStateAbbreviation](
	[InterventionStudyIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[StateAbbreviationTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStudyStateAbbreviation] PRIMARY KEY CLUSTERED 
(
	[InterventionStudyIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[StateAbbreviationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionStudyURI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionStudyURI](
	[InterventionStudyIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[URI] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionStudyURI] PRIMARY KEY CLUSTERED 
(
	[InterventionStudyIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[URI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[InterventionURI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[InterventionURI](
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[URI] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterventionURI] PRIMARY KEY CLUSTERED 
(
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[URI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LanguageDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LanguageDescriptor](
	[LanguageDescriptorId] [int] NOT NULL,
	[LanguageTypeId] [int] NULL,
 CONSTRAINT [PK_LanguageDescriptor] PRIMARY KEY CLUSTERED 
(
	[LanguageDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LanguageType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LanguageType](
	[LanguageTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LanguagesType] PRIMARY KEY CLUSTERED 
(
	[LanguageTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LanguageUseType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LanguageUseType](
	[LanguageUseTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LanguageUseType] PRIMARY KEY CLUSTERED 
(
	[LanguageUseTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LearningObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LearningObjective](
	[Objective] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[LearningObjectiveId] [nvarchar](60) NULL,
	[Description] [nvarchar](1024) NULL,
	[ParentObjective] [nvarchar](60) NULL,
	[ParentAcademicSubjectDescriptorId] [int] NULL,
	[ParentObjectiveGradeLevelDescriptorId] [int] NULL,
	[Nomenclature] [nvarchar](35) NULL,
	[SuccessCriteria] [nvarchar](150) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearningObjective] PRIMARY KEY CLUSTERED 
(
	[Objective] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LearningObjectiveContentStandard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LearningObjectiveContentStandard](
	[Objective] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[Title] [nvarchar](75) NOT NULL,
	[Version] [nvarchar](50) NULL,
	[URI] [nvarchar](255) NULL,
	[PublicationDate] [date] NULL,
	[PublicationYear] [smallint] NULL,
	[PublicationStatusTypeId] [int] NULL,
	[MandatingEducationOrganizationId] [int] NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearningObjectiveContentStandard] PRIMARY KEY CLUSTERED 
(
	[Objective] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LearningObjectiveContentStandardAuthor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LearningObjectiveContentStandardAuthor](
	[Objective] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[Author] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearningObjectiveContentStandardAuthor] PRIMARY KEY CLUSTERED 
(
	[Objective] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC,
	[Author] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LearningObjectiveLearningStandard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LearningObjectiveLearningStandard](
	[Objective] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearningObjectiveLearningStandard] PRIMARY KEY CLUSTERED 
(
	[Objective] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC,
	[LearningStandardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LearningStandard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LearningStandard](
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[ParentLearningStandardId] [nvarchar](60) NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[LearningStandardItemCode] [nvarchar](60) NULL,
	[URI] [nvarchar](255) NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[CourseTitle] [nvarchar](60) NULL,
	[SuccessCriteria] [nvarchar](150) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearningStandard] PRIMARY KEY CLUSTERED 
(
	[LearningStandardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LearningStandardContentStandard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LearningStandardContentStandard](
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[Title] [nvarchar](75) NOT NULL,
	[Version] [nvarchar](50) NULL,
	[URI] [nvarchar](255) NULL,
	[PublicationDate] [date] NULL,
	[PublicationYear] [smallint] NULL,
	[PublicationStatusTypeId] [int] NULL,
	[MandatingEducationOrganizationId] [int] NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearningStandardContentStandard] PRIMARY KEY CLUSTERED 
(
	[LearningStandardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LearningStandardContentStandardAuthor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LearningStandardContentStandardAuthor](
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[Author] [nvarchar](255) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearningStandardContentStandardAuthor] PRIMARY KEY CLUSTERED 
(
	[LearningStandardId] ASC,
	[Author] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LearningStandardIdentificationCode]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LearningStandardIdentificationCode](
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[ContentStandardName] [nvarchar](65) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearningStandardIdentificationCode] PRIMARY KEY CLUSTERED 
(
	[LearningStandardId] ASC,
	[IdentificationCode] ASC,
	[ContentStandardName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LearningStandardPrerequisiteLearningStandard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LearningStandardPrerequisiteLearningStandard](
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[PrerequisiteLearningStandardId] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearningStandardPrerequisiteLearningStandard] PRIMARY KEY CLUSTERED 
(
	[LearningStandardId] ASC,
	[PrerequisiteLearningStandardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LeaveEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LeaveEvent](
	[StaffUSI] [int] NOT NULL,
	[EventDate] [date] NOT NULL,
	[LeaveEventCategoryTypeId] [int] NOT NULL,
	[LeaveEventReason] [nvarchar](40) NULL,
	[HoursOnLeave] [decimal](18, 2) NULL,
	[SubstituteAssigned] [bit] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LeaveEvent] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[EventDate] ASC,
	[LeaveEventCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LeaveEventCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LeaveEventCategoryType](
	[LeaveEventCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LeaveEventCategoryType] PRIMARY KEY CLUSTERED 
(
	[LeaveEventCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LevelDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LevelDescriptor](
	[LevelDescriptorId] [int] NOT NULL,
 CONSTRAINT [PK_LevelDescriptor] PRIMARY KEY CLUSTERED 
(
	[LevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LevelDescriptorGradeLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LevelDescriptorGradeLevel](
	[LevelDescriptorId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LevelDescriptorGradeLevel] PRIMARY KEY CLUSTERED 
(
	[LevelDescriptorId] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LevelOfEducationDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LevelOfEducationDescriptor](
	[LevelOfEducationDescriptorId] [int] NOT NULL,
	[LevelOfEducationTypeId] [int] NULL,
 CONSTRAINT [PK_LevelOfEducationDescriptor] PRIMARY KEY CLUSTERED 
(
	[LevelOfEducationDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LevelOfEducationType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LevelOfEducationType](
	[LevelOfEducationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LevelOfEducationType] PRIMARY KEY CLUSTERED 
(
	[LevelOfEducationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LimitedEnglishProficiencyDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LimitedEnglishProficiencyDescriptor](
	[LimitedEnglishProficiencyDescriptorId] [int] NOT NULL,
	[LimitedEnglishProficiencyTypeId] [int] NOT NULL,
 CONSTRAINT [PK_LimitedEnglishProficiencyDescriptor] PRIMARY KEY CLUSTERED 
(
	[LimitedEnglishProficiencyDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LimitedEnglishProficiencyType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LimitedEnglishProficiencyType](
	[LimitedEnglishProficiencyTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LimitedEnglishProficiencyType] PRIMARY KEY CLUSTERED 
(
	[LimitedEnglishProficiencyTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LocalEducationAgency]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LocalEducationAgency](
	[LocalEducationAgencyId] [int] NOT NULL,
	[ParentLocalEducationAgencyId] [int] NULL,
	[LocalEducationAgencyCategoryTypeId] [int] NOT NULL,
	[CharterStatusTypeId] [int] NULL,
	[EducationServiceCenterId] [int] NULL,
	[StateEducationAgencyId] [int] NULL,
 CONSTRAINT [PK_LocalEducationAgency] PRIMARY KEY CLUSTERED 
(
	[LocalEducationAgencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LocalEducationAgencyAccountability]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LocalEducationAgencyAccountability](
	[LocalEducationAgencyId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[GunFreeSchoolsActReportingStatusTypeId] [int] NULL,
	[SchoolChoiceImplementStatusTypeId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LocalEducationAgencyAccountability] PRIMARY KEY CLUSTERED 
(
	[LocalEducationAgencyId] ASC,
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LocalEducationAgencyCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LocalEducationAgencyCategoryType](
	[LocalEducationAgencyCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LEACategoryType] PRIMARY KEY CLUSTERED 
(
	[LocalEducationAgencyCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[LocalEducationAgencyFederalFunds]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[LocalEducationAgencyFederalFunds](
	[LocalEducationAgencyId] [int] NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[InnovativeDollarsSpent] [money] NULL,
	[InnovativeDollarsSpentOnStrategicPriorities] [money] NULL,
	[InnovativeProgramsFundsReceived] [money] NULL,
	[SchoolImprovementAllocation] [money] NULL,
	[SupplementalEducationalServicesFundsSpent] [money] NULL,
	[SupplementalEducationalServicesPerPupilExpenditure] [money] NULL,
	[SchoolImprovementReservedFundsPercentage] [decimal](5, 4) NULL,
	[StateAssessmentAdministrationFunding] [decimal](5, 4) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LocalEducationAgencyFederalFunds] PRIMARY KEY CLUSTERED 
(
	[LocalEducationAgencyId] ASC,
	[FiscalYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Location]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Location](
	[SchoolId] [int] NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[MaximumNumberOfSeats] [int] NULL,
	[OptimalNumberOfSeats] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[ClassroomIdentificationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[MagnetSpecialProgramEmphasisSchoolType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[MagnetSpecialProgramEmphasisSchoolType](
	[MagnetSpecialProgramEmphasisSchoolTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MagnetSpecialProgramEmphasisSchoolType] PRIMARY KEY CLUSTERED 
(
	[MagnetSpecialProgramEmphasisSchoolTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[MediumOfInstructionType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[MediumOfInstructionType](
	[MediumOfInstructionTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MediumOfInstructionType] PRIMARY KEY CLUSTERED 
(
	[MediumOfInstructionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[MeetingDayType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[MeetingDayType](
	[MeetingDayTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MeetingDaysType] PRIMARY KEY CLUSTERED 
(
	[MeetingDayTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[MethodCreditEarnedType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[MethodCreditEarnedType](
	[MethodCreditEarnedTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MethodCreditEarnedType] PRIMARY KEY CLUSTERED 
(
	[MethodCreditEarnedTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[NetworkPurposeType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[NetworkPurposeType](
	[NetworkPurposeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[CodeValue] [nvarchar](50) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_NetworkPurposeType] PRIMARY KEY CLUSTERED 
(
	[NetworkPurposeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ObjectiveAssessment]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ObjectiveAssessment](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[ParentIdentificationCode] [nvarchar](60) NULL,
	[MaxRawScore] [int] NULL,
	[PercentOfAssessment] [decimal](6, 2) NULL,
	[Nomenclature] [nvarchar](35) NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ObjectiveAssessment] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ObjectiveAssessmentAssessmentItem]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ObjectiveAssessmentAssessmentItem](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[AssessmentItemIdentificationCode] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ObjectiveAssessmentAssessmentItem] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC,
	[AssessmentItemIdentificationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ObjectiveAssessmentLearningObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ObjectiveAssessmentLearningObjective](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[Objective] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ObjectiveAssessmentLearningObjective_1] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC,
	[Objective] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ObjectiveAssessmentLearningStandard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ObjectiveAssessmentLearningStandard](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ObjectiveAssessmentLearningStandard] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC,
	[LearningStandardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ObjectiveAssessmentPerformanceLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ObjectiveAssessmentPerformanceLevel](
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[PerformanceLevelDescriptorId] [int] NOT NULL,
	[AssessmentReportingMethodTypeId] [int] NOT NULL,
	[MinimumScore] [nvarchar](35) NULL,
	[MaximumScore] [nvarchar](35) NULL,
	[ResultDatatypeTypeId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ObjectiveAssessmentPerformanceLevel] PRIMARY KEY CLUSTERED 
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC,
	[PerformanceLevelDescriptorId] ASC,
	[AssessmentReportingMethodTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[OldEthnicityType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[OldEthnicityType](
	[OldEthnicityTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_OldEthnicityType] PRIMARY KEY CLUSTERED 
(
	[OldEthnicityTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[OpenStaffPosition]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[OpenStaffPosition](
	[EducationOrganizationId] [int] NOT NULL,
	[EmploymentStatusDescriptorId] [int] NOT NULL,
	[StaffClassificationDescriptorId] [int] NOT NULL,
	[RequisitionNumber] [nvarchar](20) NOT NULL,
	[DatePosted] [date] NOT NULL,
	[PositionTitle] [nvarchar](100) NULL,
	[ProgramAssignmentDescriptorId] [int] NULL,
	[DatePostingRemoved] [date] NULL,
	[PostingResultTypeId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_OpenStaffPosition] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[EmploymentStatusDescriptorId] ASC,
	[StaffClassificationDescriptorId] ASC,
	[RequisitionNumber] ASC,
	[DatePosted] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[OpenStaffPositionAcademicSubject]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[OpenStaffPositionAcademicSubject](
	[EducationOrganizationId] [int] NOT NULL,
	[StaffClassificationDescriptorId] [int] NOT NULL,
	[RequisitionNumber] [nvarchar](20) NOT NULL,
	[DatePosted] [date] NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[EmploymentStatusDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_OpenStaffPositionAcademicSubjects] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[StaffClassificationDescriptorId] ASC,
	[RequisitionNumber] ASC,
	[DatePosted] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[EmploymentStatusDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[OpenStaffPositionInstructionalGradeLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[OpenStaffPositionInstructionalGradeLevel](
	[EducationOrganizationId] [int] NOT NULL,
	[StaffClassificationDescriptorId] [int] NOT NULL,
	[RequisitionNumber] [nvarchar](20) NOT NULL,
	[DatePosted] [date] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[EmploymentStatusDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_OpenStaffPositionInstructionalGradeLevels] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[StaffClassificationDescriptorId] ASC,
	[RequisitionNumber] ASC,
	[DatePosted] ASC,
	[GradeLevelDescriptorId] ASC,
	[EmploymentStatusDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[OperationalStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[OperationalStatusType](
	[OperationalStatusTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_OperationalStatusType] PRIMARY KEY CLUSTERED 
(
	[OperationalStatusTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[OtherNameType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[OtherNameType](
	[OtherNameTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_OtherNameType] PRIMARY KEY CLUSTERED 
(
	[OtherNameTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Parent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Parent](
	[ParentUSI] [int] IDENTITY(1,1) NOT NULL,
	[PersonalTitlePrefix] [nvarchar](75) NULL,
	[FirstName] [nvarchar](75) NOT NULL,
	[MiddleName] [nvarchar](75) NULL,
	[LastSurname] [nvarchar](75) NOT NULL,
	[GenerationCodeSuffix] [nvarchar](75) NULL,
	[MaidenName] [nvarchar](75) NULL,
	[SexTypeId] [int] NULL,
	[LoginId] [nvarchar](60) NULL,
	[ParentUniqueId] [nvarchar](32) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Parent] PRIMARY KEY CLUSTERED 
(
	[ParentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ParentAddress]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ParentAddress](
	[ParentUSI] [int] NOT NULL,
	[AddressTypeId] [int] NOT NULL,
	[StreetNumberName] [nvarchar](150) NOT NULL,
	[ApartmentRoomSuiteNumber] [nvarchar](50) NULL,
	[BuildingSiteNumber] [nvarchar](20) NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateAbbreviationTypeId] [int] NOT NULL,
	[PostalCode] [nvarchar](17) NOT NULL,
	[NameOfCounty] [nvarchar](30) NULL,
	[CountyFIPSCode] [nvarchar](5) NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ParentAddress] PRIMARY KEY CLUSTERED 
(
	[ParentUSI] ASC,
	[AddressTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ParentElectronicMail]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ParentElectronicMail](
	[ParentUSI] [int] NOT NULL,
	[ElectronicMailTypeId] [int] NOT NULL,
	[ElectronicMailAddress] [nvarchar](128) NOT NULL,
	[PrimaryEmailAddressIndicator] [bit] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ParentElectronicMail] PRIMARY KEY CLUSTERED 
(
	[ParentUSI] ASC,
	[ElectronicMailTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ParentIdentificationDocument]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ParentIdentificationDocument](
	[DocumentTitle] [nvarchar](60) NULL,
	[PersonalInformationVerificationTypeId] [int] NOT NULL,
	[DocumentExpirationDate] [date] NULL,
	[IssuerDocumentIdentificationCode] [nvarchar](60) NULL,
	[IssuerName] [nvarchar](150) NULL,
	[IdentificationDocumentUseTypeId] [int] NOT NULL,
	[ParentUSI] [int] NOT NULL,
	[IssuerCountryTypeId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ParentIdentificationDocument] PRIMARY KEY CLUSTERED 
(
	[PersonalInformationVerificationTypeId] ASC,
	[IdentificationDocumentUseTypeId] ASC,
	[ParentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ParentInternationalAddress]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ParentInternationalAddress](
	[ParentUSI] [int] NOT NULL,
	[AddressTypeId] [int] NOT NULL,
	[AddressLine1] [nvarchar](150) NOT NULL,
	[AddressLine2] [nvarchar](150) NULL,
	[AddressLine3] [nvarchar](150) NULL,
	[AddressLine4] [nvarchar](150) NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CountryTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ParentInternationalAddress] PRIMARY KEY CLUSTERED 
(
	[ParentUSI] ASC,
	[AddressTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ParentOtherName]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ParentOtherName](
	[ParentUSI] [int] NOT NULL,
	[OtherNameTypeId] [int] NOT NULL,
	[PersonalTitlePrefix] [nvarchar](75) NULL,
	[FirstName] [nvarchar](75) NOT NULL,
	[MiddleName] [nvarchar](75) NULL,
	[LastSurname] [nvarchar](75) NOT NULL,
	[GenerationCodeSuffix] [nvarchar](75) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ParentOtherName] PRIMARY KEY CLUSTERED 
(
	[ParentUSI] ASC,
	[OtherNameTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ParentTelephone]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ParentTelephone](
	[ParentUSI] [int] NOT NULL,
	[TelephoneNumberTypeId] [int] NOT NULL,
	[OrderOfPriority] [int] NULL,
	[TextMessageCapabilityIndicator] [bit] NULL,
	[TelephoneNumber] [nvarchar](24) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ParentTelephone] PRIMARY KEY CLUSTERED 
(
	[ParentUSI] ASC,
	[TelephoneNumberTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Payroll]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Payroll](
	[StaffUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[AccountNumber] [nvarchar](50) NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[AmountToDate] [money] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Payroll] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[EducationOrganizationId] ASC,
	[AccountNumber] ASC,
	[FiscalYear] ASC,
	[AsOfDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PerformanceBaseConversionType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PerformanceBaseConversionType](
	[PerformanceBaseConversionTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PerformanceBaseType] PRIMARY KEY CLUSTERED 
(
	[PerformanceBaseConversionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PerformanceLevelDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PerformanceLevelDescriptor](
	[PerformanceLevelDescriptorId] [int] NOT NULL,
	[PerformanceBaseConversionTypeId] [int] NULL,
 CONSTRAINT [PK_PerformanceLevelDescriptor] PRIMARY KEY CLUSTERED 
(
	[PerformanceLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PersonalInformationVerificationType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PersonalInformationVerificationType](
	[PersonalInformationVerificationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DocumentCategoryType] PRIMARY KEY CLUSTERED 
(
	[PersonalInformationVerificationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PopulationServedType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PopulationServedType](
	[PopulationServedTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PopulationServedType] PRIMARY KEY CLUSTERED 
(
	[PopulationServedTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PostingResultType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PostingResultType](
	[PostingResultTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PostingResultType] PRIMARY KEY CLUSTERED 
(
	[PostingResultTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PostSecondaryEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PostSecondaryEvent](
	[StudentUSI] [int] NOT NULL,
	[PostSecondaryEventCategoryTypeId] [int] NOT NULL,
	[EventDate] [date] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PostSecondaryEvent] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[PostSecondaryEventCategoryTypeId] ASC,
	[EventDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PostSecondaryEventCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PostSecondaryEventCategoryType](
	[PostSecondaryEventCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PostSecondaryEventCategoryType] PRIMARY KEY CLUSTERED 
(
	[PostSecondaryEventCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PostSecondaryEventPostSecondaryInstitution]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PostSecondaryEventPostSecondaryInstitution](
	[StudentUSI] [int] NOT NULL,
	[PostSecondaryEventCategoryTypeId] [int] NOT NULL,
	[EventDate] [date] NOT NULL,
	[NameOfInstitution] [nvarchar](75) NOT NULL,
	[PostSecondaryInstitutionId] [nvarchar](30) NULL,
	[PostSecondaryInstitutionLevelTypeId] [int] NULL,
	[AdministrativeFundingControlDescriptorId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PostSecondaryEventPostSecondaryInstitution] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[PostSecondaryEventCategoryTypeId] ASC,
	[EventDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PostSecondaryEventPostSecondaryInstitutionIdentificationCode]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionIdentificationCode](
	[StudentUSI] [int] NOT NULL,
	[PostSecondaryEventCategoryTypeId] [int] NOT NULL,
	[EventDate] [date] NOT NULL,
	[EducationOrganizationIdentificationSystemTypeId] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PostSecondaryEventPostSecondaryInstitutionIdentificationCode] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[PostSecondaryEventCategoryTypeId] ASC,
	[EventDate] ASC,
	[EducationOrganizationIdentificationSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction](
	[StudentUSI] [int] NOT NULL,
	[PostSecondaryEventCategoryTypeId] [int] NOT NULL,
	[EventDate] [date] NOT NULL,
	[MediumOfInstructionTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[PostSecondaryEventCategoryTypeId] ASC,
	[EventDate] ASC,
	[MediumOfInstructionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PostSecondaryInstitutionLevelType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PostSecondaryInstitutionLevelType](
	[PostSecondaryInstitutionLevelTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PostSecondaryInstitutionLevelType] PRIMARY KEY CLUSTERED 
(
	[PostSecondaryInstitutionLevelTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Program]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Program](
	[EducationOrganizationId] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[ProgramId] [nvarchar](20) NULL,
	[ProgramSponsorTypeId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Program] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramAssignmentDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramAssignmentDescriptor](
	[ProgramAssignmentDescriptorId] [int] NOT NULL,
	[ProgramAssignmentTypeId] [int] NULL,
 CONSTRAINT [PK_ProgramAssignmentDescriptor] PRIMARY KEY CLUSTERED 
(
	[ProgramAssignmentDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramAssignmentType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramAssignmentType](
	[ProgramAssignmentTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProgramAssignmentType] PRIMARY KEY CLUSTERED 
(
	[ProgramAssignmentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramCharacteristic]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramCharacteristic](
	[EducationOrganizationId] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramCharacteristicDescriptorId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProgramCharacteristic] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[ProgramTypeId] ASC,
	[ProgramCharacteristicDescriptorId] ASC,
	[ProgramName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramCharacteristicDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramCharacteristicDescriptor](
	[ProgramCharacteristicDescriptorId] [int] NOT NULL,
	[ProgramCharacteristicTypeId] [int] NOT NULL,
 CONSTRAINT [PK_ProgramCharacteristicDescriptor] PRIMARY KEY CLUSTERED 
(
	[ProgramCharacteristicDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramCharacteristicType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramCharacteristicType](
	[ProgramCharacteristicTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProgramCharacteristicType] PRIMARY KEY CLUSTERED 
(
	[ProgramCharacteristicTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramLearningObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramLearningObjective](
	[EducationOrganizationId] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[Objective] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProgramLearningStandard] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[ProgramTypeId] ASC,
	[Objective] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC,
	[ProgramName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramLearningStandard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramLearningStandard](
	[EducationOrganizationId] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[LearningStandardId] [nvarchar](60) NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProgramLearningObjective] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[ProgramTypeId] ASC,
	[LearningStandardId] ASC,
	[ProgramName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramService]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramService](
	[EducationOrganizationId] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ServiceDescriptorId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProgramService] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[ProgramTypeId] ASC,
	[ServiceDescriptorId] ASC,
	[ProgramName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramSponsorType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramSponsorType](
	[ProgramSponsorTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProgramSponsorType] PRIMARY KEY CLUSTERED 
(
	[ProgramSponsorTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ProgramType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ProgramType](
	[ProgramTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProgramType] PRIMARY KEY CLUSTERED 
(
	[ProgramTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[PublicationStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[PublicationStatusType](
	[PublicationStatusTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_PublicationStatusType] PRIMARY KEY CLUSTERED 
(
	[PublicationStatusTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[RaceType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[RaceType](
	[RaceTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RaceType] PRIMARY KEY CLUSTERED 
(
	[RaceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ReasonExitedDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ReasonExitedDescriptor](
	[ReasonExitedDescriptorId] [int] NOT NULL,
	[ReasonExitedTypeId] [int] NULL,
 CONSTRAINT [PK_ReasonExitedDescriptor] PRIMARY KEY CLUSTERED 
(
	[ReasonExitedDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ReasonExitedType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ReasonExitedType](
	[ReasonExitedTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ReasonExitedType] PRIMARY KEY CLUSTERED 
(
	[ReasonExitedTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ReasonNotTestedType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ReasonNotTestedType](
	[ReasonNotTestedTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ReasonNotTestedType] PRIMARY KEY CLUSTERED 
(
	[ReasonNotTestedTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[RecognitionType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[RecognitionType](
	[RecognitionTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RecognitionType] PRIMARY KEY CLUSTERED 
(
	[RecognitionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[RelationType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[RelationType](
	[RelationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RelationType] PRIMARY KEY CLUSTERED 
(
	[RelationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[RepeatIdentifierType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[RepeatIdentifierType](
	[RepeatIdentifierTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RepeatIdentifierType] PRIMARY KEY CLUSTERED 
(
	[RepeatIdentifierTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ReportCard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ReportCard](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[GradingPeriodEducationOrganizationId] [int] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[GradingPeriodBeginDate] [date] NOT NULL,
	[GPAGivenGradingPeriod] [decimal](18, 4) NULL,
	[GPACumulative] [decimal](18, 4) NULL,
	[NumberOfDaysAbsent] [decimal](18, 4) NULL,
	[NumberOfDaysInAttendance] [decimal](18, 4) NULL,
	[NumberOfDaysTardy] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ReportCard] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[GradingPeriodEducationOrganizationId] ASC,
	[GradingPeriodDescriptorId] ASC,
	[GradingPeriodBeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ReportCardGrade]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ReportCardGrade](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[GradingPeriodEducationOrganizationId] [int] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[GradingPeriodBeginDate] [date] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[GradeTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ReportCardGrade] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[GradingPeriodEducationOrganizationId] ASC,
	[GradingPeriodDescriptorId] ASC,
	[GradingPeriodBeginDate] ASC,
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[BeginDate] ASC,
	[GradeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ReportCardStudentCompetencyObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ReportCardStudentCompetencyObjective](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[GradingPeriodEducationOrganizationId] [int] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[GradingPeriodBeginDate] [date] NOT NULL,
	[Objective] [nvarchar](60) NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[ObjectiveEducationOrganizationId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ReportCardStudentCompetencyObjective] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[GradingPeriodEducationOrganizationId] ASC,
	[GradingPeriodDescriptorId] ASC,
	[GradingPeriodBeginDate] ASC,
	[Objective] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC,
	[ObjectiveEducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ReportCardStudentLearningObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ReportCardStudentLearningObjective](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[GradingPeriodEducationOrganizationId] [int] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[GradingPeriodBeginDate] [date] NOT NULL,
	[Objective] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ReportCardStudentLearningObjective] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[GradingPeriodEducationOrganizationId] ASC,
	[GradingPeriodDescriptorId] ASC,
	[GradingPeriodBeginDate] ASC,
	[Objective] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ReporterDescriptionDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ReporterDescriptionDescriptor](
	[ReporterDescriptionDescriptorId] [int] NOT NULL,
	[ReporterDescriptionTypeId] [int] NULL,
 CONSTRAINT [PK_ReporterDescriptionDescriptor] PRIMARY KEY CLUSTERED 
(
	[ReporterDescriptionDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ReporterDescriptionType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ReporterDescriptionType](
	[ReporterDescriptionTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ReporterDescriptionType] PRIMARY KEY CLUSTERED 
(
	[ReporterDescriptionTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ResidencyStatusDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ResidencyStatusDescriptor](
	[ResidencyStatusDescriptorId] [int] NOT NULL,
	[ResidencyStatusTypeId] [int] NULL,
 CONSTRAINT [PK_ResidencyStatusDescriptor] PRIMARY KEY CLUSTERED 
(
	[ResidencyStatusDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ResidencyStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ResidencyStatusType](
	[ResidencyStatusTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ResidencyStatusType] PRIMARY KEY CLUSTERED 
(
	[ResidencyStatusTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ResponseIndicatorType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ResponseIndicatorType](
	[ResponseIndicatorTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ResponseIndicatorType] PRIMARY KEY CLUSTERED 
(
	[ResponseIndicatorTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ResponsibilityDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ResponsibilityDescriptor](
	[ResponsibilityDescriptorId] [int] NOT NULL,
	[ResponsibilityTypeId] [int] NULL,
 CONSTRAINT [PK_ResponsibilityDescriptor] PRIMARY KEY CLUSTERED 
(
	[ResponsibilityDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ResponsibilityType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ResponsibilityType](
	[ResponsibilityTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ResponsibilityType] PRIMARY KEY CLUSTERED 
(
	[ResponsibilityTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[RestraintEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[RestraintEvent](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[RestraintEventIdentifier] [nvarchar](20) NOT NULL,
	[EventDate] [date] NOT NULL,
	[EducationalEnvironmentTypeId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RestraintEvent] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[RestraintEventIdentifier] ASC,
	[EventDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[RestraintEventProgram]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[RestraintEventProgram](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[RestraintEventIdentifier] [nvarchar](20) NOT NULL,
	[EventDate] [date] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RestraintEventProgram] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[RestraintEventIdentifier] ASC,
	[EventDate] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[RestraintEventReason]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[RestraintEventReason](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[RestraintEventIdentifier] [nvarchar](20) NOT NULL,
	[EventDate] [date] NOT NULL,
	[RestraintEventReasonTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RestraintEventReason] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[RestraintEventIdentifier] ASC,
	[EventDate] ASC,
	[RestraintEventReasonTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[RestraintEventReasonType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[RestraintEventReasonType](
	[RestraintEventReasonTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RestraintEventReasonsType] PRIMARY KEY CLUSTERED 
(
	[RestraintEventReasonTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ResultDatatypeType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ResultDatatypeType](
	[ResultDatatypeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ResultDatatypeType] PRIMARY KEY CLUSTERED 
(
	[ResultDatatypeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[RetestIndicatorType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[RetestIndicatorType](
	[RetestIndicatorTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RetestIndicatorType] PRIMARY KEY CLUSTERED 
(
	[RetestIndicatorTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[School]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[School](
	[SchoolId] [int] NOT NULL,
	[LocalEducationAgencyId] [int] NULL,
	[SchoolTypeId] [int] NULL,
	[CharterStatusTypeId] [int] NULL,
	[TitleIPartASchoolDesignationTypeId] [int] NULL,
	[MagnetSpecialProgramEmphasisSchoolTypeId] [int] NULL,
	[AdministrativeFundingControlDescriptorId] [int] NULL,
	[InternetAccessTypeId] [int] NULL,
 CONSTRAINT [PK_School] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SchoolCategory]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SchoolCategory](
	[SchoolId] [int] NOT NULL,
	[SchoolCategoryTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SchoolCategory] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[SchoolCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SchoolCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SchoolCategoryType](
	[SchoolCategoryTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SchoolCategoryType] PRIMARY KEY CLUSTERED 
(
	[SchoolCategoryTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SchoolChoiceImplementStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SchoolChoiceImplementStatusType](
	[SchoolChoiceImplementStatusTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SchoolChoiceImplementStatusType] PRIMARY KEY CLUSTERED 
(
	[SchoolChoiceImplementStatusTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SchoolFoodServicesEligibilityDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SchoolFoodServicesEligibilityDescriptor](
	[SchoolFoodServicesEligibilityDescriptorId] [int] NOT NULL,
	[SchoolFoodServicesEligibilityTypeId] [int] NULL,
 CONSTRAINT [PK_SchoolFoodServicesEligibilityDescriptor] PRIMARY KEY CLUSTERED 
(
	[SchoolFoodServicesEligibilityDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SchoolFoodServicesEligibilityType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SchoolFoodServicesEligibilityType](
	[SchoolFoodServicesEligibilityTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SchoolFoodServicesEligibilityType] PRIMARY KEY CLUSTERED 
(
	[SchoolFoodServicesEligibilityTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SchoolGradeLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SchoolGradeLevel](
	[SchoolId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SchoolGradeLevel] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SchoolType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SchoolType](
	[SchoolTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SchoolType] PRIMARY KEY CLUSTERED 
(
	[SchoolTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SchoolYearType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SchoolYearType](
	[SchoolYear] [smallint] NOT NULL,
	[SchoolYearDescription] [nvarchar](50) NOT NULL,
	[CurrentSchoolYear] [bit] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SchoolYearType] PRIMARY KEY CLUSTERED 
(
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Section]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Section](
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[UniqueSectionCode] [nvarchar](255) NOT NULL,
	[SequenceOfCourse] [int] NOT NULL,
	[EducationalEnvironmentTypeId] [int] NULL,
	[MediumOfInstructionTypeId] [int] NULL,
	[PopulationServedTypeId] [int] NULL,
	[AvailableCreditTypeId] [int] NULL,
	[AvailableCreditConversion] [decimal](9, 2) NULL,
	[InstructionLanguageDescriptorId] [int] NULL,
	[AvailableCredit] [decimal](9, 2) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Section] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SectionAttendanceTakenEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SectionAttendanceTakenEvent](
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[Date] [date] NOT NULL,
	[EventDate] [date] NOT NULL,
	[StaffUSI] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [SectionAttendanceTakenEvent_PK] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SectionCharacteristic]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SectionCharacteristic](
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[SectionCharacteristicDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SectionCharacteristic] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[SectionCharacteristicDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SectionCharacteristicDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SectionCharacteristicDescriptor](
	[SectionCharacteristicDescriptorId] [int] NOT NULL,
	[SectionCharacteristicTypeId] [int] NULL,
 CONSTRAINT [PK_SectionCharacteristicDescriptor] PRIMARY KEY CLUSTERED 
(
	[SectionCharacteristicDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SectionCharacteristicType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SectionCharacteristicType](
	[SectionCharacteristicTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SectionCharacteristicsType] PRIMARY KEY CLUSTERED 
(
	[SectionCharacteristicTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SectionProgram]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SectionProgram](
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SectionProgram] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[EducationOrganizationId] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SeparationReasonDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SeparationReasonDescriptor](
	[SeparationReasonDescriptorId] [int] NOT NULL,
	[SeparationReasonTypeId] [int] NULL,
 CONSTRAINT [PK_SeparationReasonDescriptor] PRIMARY KEY CLUSTERED 
(
	[SeparationReasonDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SeparationReasonType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SeparationReasonType](
	[SeparationReasonTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SeparationReasonType] PRIMARY KEY CLUSTERED 
(
	[SeparationReasonTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SeparationType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SeparationType](
	[SeparationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SeparationType] PRIMARY KEY CLUSTERED 
(
	[SeparationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[ServiceDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[ServiceDescriptor](
	[ServiceDescriptorId] [int] NOT NULL,
	[ServiceCategory] [nvarchar](50) NULL,
 CONSTRAINT [PK_ServiceDescriptor] PRIMARY KEY CLUSTERED 
(
	[ServiceDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Session]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Session](
	[SchoolId] [int] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[SessionName] [nvarchar](60) NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[TotalInstructionalDays] [int] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Session] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SessionAcademicWeek]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SessionAcademicWeek](
	[SchoolId] [int] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[WeekIdentifier] [nvarchar](80) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SessionAcademicWeek] PRIMARY KEY CLUSTERED 
(
	[SchoolId] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[EducationOrganizationId] ASC,
	[WeekIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SessionGradingPeriod]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SessionGradingPeriod](
	[EducationOrganizationId] [int] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SessionGradingPeriod] PRIMARY KEY CLUSTERED 
(
	[EducationOrganizationId] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[GradingPeriodDescriptorId] ASC,
	[BeginDate] ASC,
	[SchoolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SexType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SexType](
	[SexTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SexType] PRIMARY KEY CLUSTERED 
(
	[SexTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SpecialEducationSettingDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SpecialEducationSettingDescriptor](
	[SpecialEducationSettingDescriptorId] [int] NOT NULL,
	[SpecialEducationSettingTypeId] [int] NULL,
 CONSTRAINT [PK_SpecialEducationSettingDescriptor] PRIMARY KEY CLUSTERED 
(
	[SpecialEducationSettingDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[SpecialEducationSettingType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[SpecialEducationSettingType](
	[SpecialEducationSettingTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SpecialEducationSettingType] PRIMARY KEY CLUSTERED 
(
	[SpecialEducationSettingTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Staff]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Staff](
	[StaffUSI] [int] IDENTITY(1,1) NOT NULL,
	[PersonalTitlePrefix] [nvarchar](75) NULL,
	[FirstName] [nvarchar](75) NOT NULL,
	[MiddleName] [nvarchar](75) NULL,
	[LastSurname] [nvarchar](75) NOT NULL,
	[GenerationCodeSuffix] [nvarchar](75) NULL,
	[MaidenName] [nvarchar](75) NULL,
	[SexTypeId] [int] NULL,
	[BirthDate] [date] NULL,
	[HispanicLatinoEthnicity] [bit] NOT NULL,
	[OldEthnicityTypeId] [int] NULL,
	[HighestCompletedLevelOfEducationDescriptorId] [int] NULL,
	[YearsOfPriorProfessionalExperience] [int] NULL,
	[YearsOfPriorTeachingExperience] [int] NULL,
	[HighlyQualifiedTeacher] [bit] NULL,
	[LoginId] [nvarchar](60) NULL,
	[CitizenshipStatusTypeId] [int] NULL,
	[StaffUniqueId] [nvarchar](32) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Staff] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffAddress]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffAddress](
	[StaffUSI] [int] NOT NULL,
	[AddressTypeId] [int] NOT NULL,
	[StreetNumberName] [nvarchar](150) NOT NULL,
	[ApartmentRoomSuiteNumber] [nvarchar](50) NULL,
	[BuildingSiteNumber] [nvarchar](20) NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateAbbreviationTypeId] [int] NOT NULL,
	[PostalCode] [nvarchar](17) NOT NULL,
	[NameOfCounty] [nvarchar](30) NULL,
	[CountyFIPSCode] [nvarchar](5) NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffAddress] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[AddressTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffClassificationDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffClassificationDescriptor](
	[StaffClassificationDescriptorId] [int] NOT NULL,
	[StaffClassificationTypeId] [int] NULL,
 CONSTRAINT [PK_StaffClassificationDescriptor] PRIMARY KEY CLUSTERED 
(
	[StaffClassificationDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffClassificationType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffClassificationType](
	[StaffClassificationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffClassificationType] PRIMARY KEY CLUSTERED 
(
	[StaffClassificationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffCohortAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffCohortAssociation](
	[StaffUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CohortIdentifier] [nvarchar](20) NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[StudentRecordAccess] [bit] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffCohortAssociation] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[EducationOrganizationId] ASC,
	[CohortIdentifier] ASC,
	[BeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffCredential]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffCredential](
	[StaffUSI] [int] NOT NULL,
	[CredentialFieldDescriptorId] [int] NOT NULL,
	[CredentialTypeId] [int] NOT NULL,
	[LevelDescriptorId] [int] NOT NULL,
	[TeachingCredentialDescriptorId] [int] NOT NULL,
	[CredentialIssuanceDate] [date] NOT NULL,
	[CredentialExpirationDate] [date] NULL,
	[TeachingCredentialBasisTypeId] [int] NULL,
	[StateOfIssueStateAbbreviationTypeId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffCredential] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[CredentialFieldDescriptorId] ASC,
	[CredentialTypeId] ASC,
	[LevelDescriptorId] ASC,
	[TeachingCredentialDescriptorId] ASC,
	[CredentialIssuanceDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffEducationOrganizationAssignmentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation](
	[StaffUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[StaffClassificationDescriptorId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[PositionTitle] [nvarchar](100) NULL,
	[EndDate] [date] NULL,
	[OrderOfAssignment] [int] NULL,
	[EmploymentEducationOrganizationId] [int] NULL,
	[EmploymentStatusDescriptorId] [int] NULL,
	[EmploymentHireDate] [date] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffEducationOrgAssignmentAssociation] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[EducationOrganizationId] ASC,
	[StaffClassificationDescriptorId] ASC,
	[BeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffEducationOrganizationEmploymentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation](
	[StaffUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[EmploymentStatusDescriptorId] [int] NOT NULL,
	[HireDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[SeparationTypeId] [int] NULL,
	[SeparationReasonDescriptorId] [int] NULL,
	[Department] [nvarchar](3) NULL,
	[FullTimeEquivalency] [decimal](5, 4) NULL,
	[OfferDate] [date] NULL,
	[HourlyWage] [money] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffEducationOrganizationEmploymentAssociation] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[EducationOrganizationId] ASC,
	[EmploymentStatusDescriptorId] ASC,
	[HireDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffElectronicMail]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffElectronicMail](
	[StaffUSI] [int] NOT NULL,
	[ElectronicMailTypeId] [int] NOT NULL,
	[ElectronicMailAddress] [nvarchar](128) NOT NULL,
	[PrimaryEmailAddressIndicator] [bit] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffElectronicMail] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[ElectronicMailTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffIdentificationCode]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffIdentificationCode](
	[StaffUSI] [int] NOT NULL,
	[StaffIdentificationSystemTypeId] [int] NOT NULL,
	[AssigningOrganizationIdentificationCode] [nvarchar](60) NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffIdentificationCode] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[StaffIdentificationSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffIdentificationDocument]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffIdentificationDocument](
	[PersonalInformationVerificationTypeId] [int] NOT NULL,
	[IdentificationDocumentUseTypeId] [int] NOT NULL,
	[StaffUSI] [int] NOT NULL,
	[DocumentTitle] [nvarchar](60) NULL,
	[DocumentExpirationDate] [date] NULL,
	[IssuerDocumentIdentificationCode] [nvarchar](60) NULL,
	[IssuerName] [nvarchar](150) NULL,
	[IssuerCountryTypeId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffIdentificationDocument] PRIMARY KEY CLUSTERED 
(
	[PersonalInformationVerificationTypeId] ASC,
	[IdentificationDocumentUseTypeId] ASC,
	[StaffUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffIdentificationSystemType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffIdentificationSystemType](
	[StaffIdentificationSystemTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffIdentificationSystemType] PRIMARY KEY CLUSTERED 
(
	[StaffIdentificationSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffInternationalAddress]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffInternationalAddress](
	[StaffUSI] [int] NOT NULL,
	[AddressTypeId] [int] NOT NULL,
	[AddressLine1] [nvarchar](150) NOT NULL,
	[AddressLine2] [nvarchar](150) NULL,
	[AddressLine3] [nvarchar](150) NULL,
	[AddressLine4] [nvarchar](150) NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CountryTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffInternationalAddress] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[AddressTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffLanguage]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffLanguage](
	[StaffUSI] [int] NOT NULL,
	[LanguageDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffLanguages] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[LanguageDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffLanguageUse]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffLanguageUse](
	[StaffUSI] [int] NOT NULL,
	[LanguageDescriptorId] [int] NOT NULL,
	[LanguageUseTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffLanguageUse] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[LanguageDescriptorId] ASC,
	[LanguageUseTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffOtherName]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffOtherName](
	[StaffUSI] [int] NOT NULL,
	[OtherNameTypeId] [int] NOT NULL,
	[PersonalTitlePrefix] [nvarchar](75) NULL,
	[FirstName] [nvarchar](75) NOT NULL,
	[MiddleName] [nvarchar](75) NULL,
	[LastSurname] [nvarchar](75) NOT NULL,
	[GenerationCodeSuffix] [nvarchar](75) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffOtherName] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[OtherNameTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffProgramAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffProgramAssociation](
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[StaffUSI] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[StudentRecordAccess] [bit] NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffProgramAssociation] PRIMARY KEY CLUSTERED 
(
	[ProgramEducationOrganizationId] ASC,
	[ProgramTypeId] ASC,
	[StaffUSI] ASC,
	[BeginDate] ASC,
	[ProgramName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffRace]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffRace](
	[StaffUSI] [int] NOT NULL,
	[RaceTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffRace] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[RaceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffSchoolAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffSchoolAssociation](
	[StaffUSI] [int] NOT NULL,
	[ProgramAssignmentDescriptorId] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[SchoolYear] [smallint] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffSchoolAssociation] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[ProgramAssignmentDescriptorId] ASC,
	[SchoolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffSchoolAssociationAcademicSubject]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffSchoolAssociationAcademicSubject](
	[StaffUSI] [int] NOT NULL,
	[ProgramAssignmentDescriptorId] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffSchoolAssociationAcademicSubject] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[ProgramAssignmentDescriptorId] ASC,
	[SchoolId] ASC,
	[AcademicSubjectDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffSchoolAssociationGradeLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffSchoolAssociationGradeLevel](
	[StaffUSI] [int] NOT NULL,
	[ProgramAssignmentDescriptorId] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffSchoolAssociationGradeLevel] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[ProgramAssignmentDescriptorId] ASC,
	[SchoolId] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffSectionAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffSectionAssociation](
	[StaffUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[ClassroomPositionDescriptorId] [int] NOT NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[HighlyQualifiedTeacher] [bit] NULL,
	[TeacherStudentDataLinkExclusion] [bit] NULL,
	[PercentageContribution] [decimal](5, 4) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TeacherSectionAssociation] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffTelephone]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffTelephone](
	[StaffUSI] [int] NOT NULL,
	[TelephoneNumberTypeId] [int] NOT NULL,
	[OrderOfPriority] [int] NULL,
	[TextMessageCapabilityIndicator] [bit] NULL,
	[TelephoneNumber] [nvarchar](24) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffTelephone] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[TelephoneNumberTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StaffVisa]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StaffVisa](
	[StaffUSI] [int] NOT NULL,
	[VisaTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StaffVisa] PRIMARY KEY CLUSTERED 
(
	[StaffUSI] ASC,
	[VisaTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StateAbbreviationType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StateAbbreviationType](
	[StateAbbreviationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StateAbbreviationType] PRIMARY KEY CLUSTERED 
(
	[StateAbbreviationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StateEducationAgency]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StateEducationAgency](
	[StateEducationAgencyId] [int] NOT NULL,
 CONSTRAINT [PK_StateEducationAgency] PRIMARY KEY CLUSTERED 
(
	[StateEducationAgencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StateEducationAgencyAccountability]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StateEducationAgencyAccountability](
	[StateEducationAgencyId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[CTEGraduationRateInclusion] [bit] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StateEducationAgencyAccountability] PRIMARY KEY CLUSTERED 
(
	[StateEducationAgencyId] ASC,
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StateEducationAgencyFederalFunds]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StateEducationAgencyFederalFunds](
	[StateEducationAgencyId] [int] NOT NULL,
	[FiscalYear] [int] NOT NULL,
	[FederalProgramsFundingAllocation] [money] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StateEducationAgencyFederalFunds] PRIMARY KEY CLUSTERED 
(
	[StateEducationAgencyId] ASC,
	[FiscalYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[Student]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[Student](
	[StudentUSI] [int] IDENTITY(1,1) NOT NULL,
	[PersonalTitlePrefix] [nvarchar](75) NULL,
	[FirstName] [nvarchar](75) NOT NULL,
	[MiddleName] [nvarchar](75) NULL,
	[LastSurname] [nvarchar](75) NOT NULL,
	[GenerationCodeSuffix] [nvarchar](75) NULL,
	[MaidenName] [nvarchar](75) NULL,
	[SexTypeId] [int] NOT NULL,
	[BirthDate] [date] NOT NULL,
	[CityOfBirth] [nvarchar](30) NULL,
	[BirthStateAbbreviationTypeId] [int] NULL,
	[BirthCountryCodeTypeId] [int] NULL,
	[DateEnteredUS] [date] NULL,
	[MultipleBirthStatus] [bit] NULL,
	[ProfileThumbnail] [nvarchar](59) NULL,
	[HispanicLatinoEthnicity] [bit] NOT NULL,
	[OldEthnicityTypeId] [int] NULL,
	[EconomicDisadvantaged] [bit] NULL,
	[SchoolFoodServicesEligibilityDescriptorId] [int] NULL,
	[LimitedEnglishProficiencyDescriptorId] [int] NULL,
	[DisplacementStatus] [nvarchar](30) NULL,
	[LoginId] [nvarchar](60) NULL,
	[InternationalProvinceOfBirth] [nvarchar](150) NULL,
	[CitizenshipStatusTypeId] [int] NULL,
	[StudentUniqueId] [nvarchar](32) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Student] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAcademicRecord]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAcademicRecord](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[CumulativeEarnedCreditTypeId] [int] NULL,
	[CumulativeEarnedCreditConversion] [decimal](9, 2) NULL,
	[CumulativeEarnedCredit] [decimal](9, 2) NULL,
	[CumulativeAttemptedCreditTypeId] [int] NULL,
	[CumulativeAttemptedCreditConversion] [decimal](9, 2) NULL,
	[CumulativeAttemptedCredit] [decimal](9, 2) NULL,
	[CumulativeGradePointsEarned] [decimal](18, 4) NULL,
	[CumulativeGradePointAverage] [decimal](18, 4) NULL,
	[GradeValueQualifier] [nvarchar](80) NULL,
	[ProjectedGraduationDate] [date] NULL,
	[SessionEarnedCreditTypeId] [int] NULL,
	[SessionEarnedCreditConversion] [decimal](9, 2) NULL,
	[SessionEarnedCredit] [decimal](9, 2) NULL,
	[SessionAttemptedCreditTypeId] [int] NULL,
	[SessionAttemptedCreditConversion] [decimal](9, 2) NULL,
	[SessionAttemptedCredit] [decimal](9, 2) NULL,
	[SessionGradePointsEarned] [decimal](18, 4) NULL,
	[SessionGradePointAverage] [decimal](18, 4) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAcademicRecord] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[SchoolYear] ASC,
	[TermTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAcademicRecordAcademicHonor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAcademicRecordAcademicHonor](
	[AcademicHonorCategoryTypeId] [int] NOT NULL,
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[HonorDescription] [nvarchar](80) NULL,
	[HonorAwardDate] [date] NULL,
	[HonorAwardExpiresDate] [date] NULL,
	[AchievementTitle] [nvarchar](60) NULL,
	[AchievementCategoryDescriptorId] [int] NOT NULL,
	[AchievementCategorySystem] [nvarchar](60) NULL,
	[IssuerName] [nvarchar](150) NULL,
	[IssuerOriginURL] [nvarchar](255) NULL,
	[Criteria] [nvarchar](150) NULL,
	[CriteriaURL] [nvarchar](255) NULL,
	[EvidenceStatement] [nvarchar](150) NULL,
	[ImageURL] [nvarchar](255) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAcademicRecordAcademicHonor] PRIMARY KEY CLUSTERED 
(
	[AcademicHonorCategoryTypeId] ASC,
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[SchoolYear] ASC,
	[TermTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAcademicRecordClassRanking]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAcademicRecordClassRanking](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[ClassRank] [int] NOT NULL,
	[TotalNumberInClass] [int] NOT NULL,
	[PercentageRanking] [int] NULL,
	[ClassRankingDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAcademicRecordClassRanking] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[SchoolYear] ASC,
	[TermTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAcademicRecordDiploma]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAcademicRecordDiploma](
	[StudentUSI] [int] NOT NULL,
	[DiplomaTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[DiplomaAwardDate] [date] NOT NULL,
	[DiplomaLevelTypeId] [int] NULL,
	[TermTypeId] [int] NOT NULL,
	[CTECompleter] [bit] NULL,
	[DiplomaDescription] [nvarchar](80) NULL,
	[DiplomaAwardExpiresDate] [date] NULL,
	[AchievementTitle] [nvarchar](60) NULL,
	[AchievementCategoryDescriptorId] [int] NOT NULL,
	[AchievementCategorySystem] [nvarchar](60) NULL,
	[IssuerName] [nvarchar](150) NULL,
	[IssuerOriginURL] [nvarchar](255) NULL,
	[Criteria] [nvarchar](150) NULL,
	[CriteriaURL] [nvarchar](255) NULL,
	[EvidenceStatement] [nvarchar](150) NULL,
	[ImageURL] [nvarchar](255) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAcademicRecordDiploma] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[DiplomaTypeId] ASC,
	[SchoolYear] ASC,
	[EducationOrganizationId] ASC,
	[DiplomaAwardDate] ASC,
	[TermTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAcademicRecordRecognition]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAcademicRecordRecognition](
	[RecognitionTypeId] [int] NOT NULL,
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[RecognitionDescription] [nvarchar](80) NULL,
	[RecognitionAwardDate] [date] NULL,
	[RecognitionAwardExpiresDate] [date] NULL,
	[AchievementTitle] [nvarchar](60) NULL,
	[AchievementCategoryDescriptorId] [int] NOT NULL,
	[AchievementCategorySystem] [nvarchar](60) NULL,
	[IssuerName] [nvarchar](150) NULL,
	[IssuerOriginURL] [nvarchar](255) NULL,
	[Criteria] [nvarchar](150) NULL,
	[CriteriaURL] [nvarchar](255) NULL,
	[EvidenceStatement] [nvarchar](150) NULL,
	[ImageURL] [nvarchar](255) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAcademicRecordRecognition] PRIMARY KEY CLUSTERED 
(
	[RecognitionTypeId] ASC,
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[SchoolYear] ASC,
	[TermTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAcademicRecordReportCard]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAcademicRecordReportCard](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[GradingPeriodEducationOrganizationId] [int] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[GradingPeriodBeginDate] [date] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAcademicRecordReportCard] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[SchoolYear] ASC,
	[TermTypeId] ASC,
	[GradingPeriodEducationOrganizationId] ASC,
	[GradingPeriodDescriptorId] ASC,
	[GradingPeriodBeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAddress]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAddress](
	[StudentUSI] [int] NOT NULL,
	[AddressTypeId] [int] NOT NULL,
	[StreetNumberName] [nvarchar](150) NOT NULL,
	[ApartmentRoomSuiteNumber] [nvarchar](50) NULL,
	[BuildingSiteNumber] [nvarchar](20) NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateAbbreviationTypeId] [int] NOT NULL,
	[PostalCode] [nvarchar](17) NOT NULL,
	[NameOfCounty] [nvarchar](30) NULL,
	[CountyFIPSCode] [nvarchar](5) NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAddress] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AddressTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAssessment]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAssessment](
	[StudentUSI] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[AdministrationDate] [date] NOT NULL,
	[AdministrationEndDate] [date] NULL,
	[SerialNumber] [nvarchar](60) NULL,
	[AdministrationLanguageDescriptorId] [int] NULL,
	[AdministrationEnvironmentTypeId] [int] NULL,
	[RetestIndicatorTypeId] [int] NULL,
	[ReasonNotTestedTypeId] [int] NULL,
	[WhenAssessedGradeLevelDescriptorId] [int] NULL,
	[EventCircumstanceTypeId] [int] NULL,
	[EventDescription] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAssessment] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[AdministrationDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAssessmentAccommodation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAssessmentAccommodation](
	[StudentUSI] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[AdministrationDate] [date] NOT NULL,
	[AccommodationDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAssessmentAccommodation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[AdministrationDate] ASC,
	[AccommodationDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAssessmentItem]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAssessmentItem](
	[StudentUSI] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[AdministrationDate] [date] NOT NULL,
	[AssessmentResponse] [nvarchar](60) NULL,
	[ResponseIndicatorTypeId] [int] NULL,
	[AssessmentItemResultTypeId] [int] NOT NULL,
	[RawScoreResult] [int] NULL,
	[TimeAssessed] [nvarchar](30) NULL,
	[DescriptiveFeedback] [nvarchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAssessmentItem] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC,
	[AdministrationDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAssessmentPerformanceLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAssessmentPerformanceLevel](
	[StudentUSI] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[AdministrationDate] [date] NOT NULL,
	[PerformanceLevelDescriptorId] [int] NOT NULL,
	[PerformanceLevelMet] [bit] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAssessmentPerformanceLevel] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[AdministrationDate] ASC,
	[PerformanceLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAssessmentScoreResult]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAssessmentScoreResult](
	[StudentUSI] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[AdministrationDate] [date] NOT NULL,
	[AssessmentReportingMethodTypeId] [int] NOT NULL,
	[Result] [nvarchar](35) NOT NULL,
	[ResultDatatypeTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAssessmentScoreResult] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[AdministrationDate] ASC,
	[AssessmentReportingMethodTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAssessmentStudentObjectiveAssessment]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAssessmentStudentObjectiveAssessment](
	[StudentUSI] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[AdministrationDate] [date] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAssessmentStudentObjectiveAssessment] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC,
	[AdministrationDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAssessmentStudentObjectiveAssessmentPerformanceLevel]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentPerformanceLevel](
	[StudentUSI] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[AdministrationDate] [date] NOT NULL,
	[PerformanceLevelDescriptorId] [int] NOT NULL,
	[PerformanceLevelMet] [bit] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAssessmentStudentObjectiveAssessmentPerformanceLevel] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC,
	[AdministrationDate] ASC,
	[PerformanceLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult](
	[StudentUSI] [int] NOT NULL,
	[AssessmentTitle] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[AssessedGradeLevelDescriptorId] [int] NOT NULL,
	[Version] [int] NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[AdministrationDate] [date] NOT NULL,
	[AssessmentReportingMethodTypeId] [int] NOT NULL,
	[Result] [nvarchar](35) NOT NULL,
	[ResultDatatypeTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentAssessmentStudentObjectiveAssessmentScoreResult] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[Version] ASC,
	[IdentificationCode] ASC,
	[AdministrationDate] ASC,
	[AssessmentReportingMethodTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentCharacteristic]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentCharacteristic](
	[StudentUSI] [int] NOT NULL,
	[StudentCharacteristicDescriptorId] [int] NOT NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[DesignatedBy] [nvarchar](60) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentCharacteristics] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[StudentCharacteristicDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentCharacteristicDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentCharacteristicDescriptor](
	[StudentCharacteristicDescriptorId] [int] NOT NULL,
	[StudentCharacteristicTypeId] [int] NULL,
 CONSTRAINT [PK_StudentCharacteristicDescriptor] PRIMARY KEY CLUSTERED 
(
	[StudentCharacteristicDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentCharacteristicType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentCharacteristicType](
	[StudentCharacteristicTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentCharacteristicsType] PRIMARY KEY CLUSTERED 
(
	[StudentCharacteristicTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentCohortAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentCohortAssociation](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CohortIdentifier] [nvarchar](20) NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentCohortAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[CohortIdentifier] ASC,
	[BeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentCohortAssociationSection]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentCohortAssociationSection](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CohortIdentifier] [nvarchar](20) NOT NULL,
	[BeginDate] [date] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentCohortAssociationSection] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[CohortIdentifier] ASC,
	[BeginDate] ASC,
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentCohortYear]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentCohortYear](
	[StudentUSI] [int] NOT NULL,
	[CohortYearTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentCohortYears] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[CohortYearTypeId] ASC,
	[SchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentCompetencyObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentCompetencyObjective](
	[StudentUSI] [int] NOT NULL,
	[GradingPeriodEducationOrganizationId] [int] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[GradingPeriodBeginDate] [date] NOT NULL,
	[Objective] [nvarchar](60) NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[ObjectiveEducationOrganizationId] [int] NOT NULL,
	[CompetencyLevelDescriptorId] [int] NOT NULL,
	[DiagnosticStatement] [nvarchar](1024) NULL,
	[SchoolId] [int] NULL,
	[ClassPeriodName] [nvarchar](20) NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NULL,
	[LocalCourseCode] [nvarchar](60) NULL,
	[TermTypeId] [int] NULL,
	[SchoolYear] [smallint] NULL,
	[BeginDate] [date] NULL,
	[ProgramEducationOrganizationId] [int] NULL,
	[ProgramTypeId] [int] NULL,
	[ProgramName] [nvarchar](60) NULL,
	[EducationOrganizationId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentCompetencyObjective] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[GradingPeriodEducationOrganizationId] ASC,
	[GradingPeriodDescriptorId] ASC,
	[GradingPeriodBeginDate] ASC,
	[Objective] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC,
	[ObjectiveEducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentCTEProgramAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentCTEProgramAssociation](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
 CONSTRAINT [PK_StudentCTEProgramAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC,
	[ProgramEducationOrganizationId] ASC,
	[BeginDate] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentCTEProgramAssociationCTEProgram]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentCTEProgramAssociationCTEProgram](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[CareerPathwayTypeId] [int] NOT NULL,
	[CIPCode] [nvarchar](120) NULL,
	[PrimaryCTEProgramIndicator] [bit] NULL,
	[CTEProgramCompletionIndicator] [bit] NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentCTEProgramAssociationCTEProgram] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramEducationOrganizationId] ASC,
	[BeginDate] ASC,
	[CareerPathwayTypeId] ASC,
	[ProgramName] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentDisability]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentDisability](
	[StudentUSI] [int] NOT NULL,
	[DisabilityDiagnosis] [nvarchar](80) NULL,
	[OrderOfDisability] [int] NULL,
	[DisabilityDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentDisability] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[DisabilityDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentDisciplineIncidentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentDisciplineIncidentAssociation](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[IncidentIdentifier] [nvarchar](20) NOT NULL,
	[StudentParticipationCodeTypeId] [int] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentDisciplineIncidentAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[IncidentIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentDisciplineIncidentAssociationBehavior]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentDisciplineIncidentAssociationBehavior](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[IncidentIdentifier] [nvarchar](20) NOT NULL,
	[BehaviorDescriptorId] [int] NOT NULL,
	[BehaviorDetailedDescription] [nvarchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentDisciplineIncidentBehavior] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[IncidentIdentifier] ASC,
	[BehaviorDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentEducationOrganizationAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentEducationOrganizationAssociation](
	[StudentUSI] [int] NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[ResponsibilityDescriptorId] [int] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentEducationOrganizationAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[EducationOrganizationId] ASC,
	[ResponsibilityDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentElectronicMail]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentElectronicMail](
	[StudentUSI] [int] NOT NULL,
	[ElectronicMailTypeId] [int] NOT NULL,
	[ElectronicMailAddress] [nvarchar](128) NOT NULL,
	[PrimaryEmailAddressIndicator] [bit] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentElectronicMail] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ElectronicMailTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentGradebookEntry]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentGradebookEntry](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[GradebookEntryTitle] [nvarchar](60) NOT NULL,
	[DateAssigned] [date] NOT NULL,
	[DateFulfilled] [date] NULL,
	[LetterGradeEarned] [nvarchar](20) NULL,
	[NumericGradeEarned] [int] NULL,
	[CompetencyLevelDescriptorId] [int] NULL,
	[DiagnosticStatement] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentGradebookEntry] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[BeginDate] ASC,
	[GradebookEntryTitle] ASC,
	[DateAssigned] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentIdentificationCode]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentIdentificationCode](
	[StudentUSI] [int] NOT NULL,
	[StudentIdentificationSystemTypeId] [int] NOT NULL,
	[AssigningOrganizationIdentificationCode] [nvarchar](60) NOT NULL,
	[IdentificationCode] [nvarchar](60) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentIdentificationCode] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[StudentIdentificationSystemTypeId] ASC,
	[AssigningOrganizationIdentificationCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentIdentificationDocument]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentIdentificationDocument](
	[PersonalInformationVerificationTypeId] [int] NOT NULL,
	[IdentificationDocumentUseTypeId] [int] NOT NULL,
	[StudentUSI] [int] NOT NULL,
	[DocumentTitle] [nvarchar](60) NULL,
	[DocumentExpirationDate] [date] NULL,
	[IssuerDocumentIdentificationCode] [nvarchar](60) NULL,
	[IssuerName] [nvarchar](150) NULL,
	[IssuerCountryTypeId] [int] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentIdentificationDocument] PRIMARY KEY CLUSTERED 
(
	[PersonalInformationVerificationTypeId] ASC,
	[IdentificationDocumentUseTypeId] ASC,
	[StudentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentIdentificationSystemType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentIdentificationSystemType](
	[StudentIdentificationSystemTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentIdentificationSystemType] PRIMARY KEY CLUSTERED 
(
	[StudentIdentificationSystemTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentIndicator]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentIndicator](
	[StudentUSI] [int] NOT NULL,
	[IndicatorName] [nvarchar](60) NOT NULL,
	[Indicator] [nvarchar](35) NOT NULL,
	[IndicatorGroup] [nvarchar](60) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[DesignatedBy] [nvarchar](60) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentIndicator] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[IndicatorName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentInternationalAddress]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentInternationalAddress](
	[StudentUSI] [int] NOT NULL,
	[AddressTypeId] [int] NOT NULL,
	[AddressLine1] [nvarchar](150) NOT NULL,
	[AddressLine2] [nvarchar](150) NULL,
	[AddressLine3] [nvarchar](150) NULL,
	[AddressLine4] [nvarchar](150) NULL,
	[Latitude] [nvarchar](20) NULL,
	[Longitude] [nvarchar](20) NULL,
	[BeginDate] [date] NULL,
	[EndDate] [date] NULL,
	[CountryTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentInternationalAddress] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[AddressTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentInterventionAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentInterventionAssociation](
	[StudentUSI] [int] NOT NULL,
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CohortEducationOrganizationId] [int] NULL,
	[CohortIdentifier] [nvarchar](20) NULL,
	[DiagnosticStatement] [nvarchar](1024) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentInterventionAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentInterventionAssociationInterventionEffectiveness]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness](
	[StudentUSI] [int] NOT NULL,
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[DiagnosisDescriptorId] [int] NOT NULL,
	[PopulationServedTypeId] [int] NOT NULL,
	[GradeLevelDescriptorId] [int] NOT NULL,
	[ImprovementIndex] [int] NULL,
	[InterventionEffectivenessRatingTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentInterventionAssociationInterventionEffectiveness] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[DiagnosisDescriptorId] ASC,
	[PopulationServedTypeId] ASC,
	[GradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentInterventionAttendanceEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentInterventionAttendanceEvent](
	[StudentUSI] [int] NOT NULL,
	[InterventionIdentificationCode] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[EventDate] [date] NOT NULL,
	[AttendanceEventReason] [nvarchar](40) NULL,
	[EducationalEnvironmentTypeId] [int] NULL,
	[AttendanceEventCategoryDescriptorId] [int] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentInterventionAttendanceEvent] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[InterventionIdentificationCode] ASC,
	[EducationOrganizationId] ASC,
	[EventDate] ASC,
	[AttendanceEventCategoryDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentLanguage]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentLanguage](
	[StudentUSI] [int] NOT NULL,
	[LanguageDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentLanguages] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[LanguageDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentLanguageUse]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentLanguageUse](
	[StudentUSI] [int] NOT NULL,
	[LanguageDescriptorId] [int] NOT NULL,
	[LanguageUseTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentLanguageUse] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[LanguageDescriptorId] ASC,
	[LanguageUseTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentLearningObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentLearningObjective](
	[StudentUSI] [int] NOT NULL,
	[GradingPeriodEducationOrganizationId] [int] NOT NULL,
	[GradingPeriodDescriptorId] [int] NOT NULL,
	[GradingPeriodBeginDate] [date] NOT NULL,
	[Objective] [nvarchar](60) NOT NULL,
	[AcademicSubjectDescriptorId] [int] NOT NULL,
	[ObjectiveGradeLevelDescriptorId] [int] NOT NULL,
	[CompetencyLevelDescriptorId] [int] NOT NULL,
	[DiagnosticStatement] [nvarchar](1024) NULL,
	[SchoolId] [int] NULL,
	[ClassPeriodName] [nvarchar](20) NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NULL,
	[LocalCourseCode] [nvarchar](60) NULL,
	[TermTypeId] [int] NULL,
	[SchoolYear] [smallint] NULL,
	[BeginDate] [date] NULL,
	[ProgramEducationOrganizationId] [int] NULL,
	[ProgramTypeId] [int] NULL,
	[ProgramName] [nvarchar](60) NULL,
	[EducationOrganizationId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentLearningObjective] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[GradingPeriodEducationOrganizationId] ASC,
	[GradingPeriodDescriptorId] ASC,
	[GradingPeriodBeginDate] ASC,
	[Objective] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[ObjectiveGradeLevelDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentLearningStyle]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentLearningStyle](
	[StudentUSI] [int] NOT NULL,
	[VisualLearning] [decimal](9, 4) NOT NULL,
	[AuditoryLearning] [decimal](9, 4) NOT NULL,
	[TactileLearning] [decimal](9, 4) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentLearningStyle] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentMigrantEducationProgramAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentMigrantEducationProgramAssociation](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[PriorityForServices] [bit] NOT NULL,
	[LastQualifyingMove] [date] NOT NULL,
	[ContinuationOfServicesReasonDescriptorId] [int] NULL,
	[USInitialEntry] [date] NULL,
	[USMostRecentEntry] [date] NULL,
	[USInitialSchoolEntry] [date] NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
 CONSTRAINT [PK_StudentMigrantEducationProgramAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC,
	[ProgramEducationOrganizationId] ASC,
	[BeginDate] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentOtherName]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentOtherName](
	[StudentUSI] [int] NOT NULL,
	[OtherNameTypeId] [int] NOT NULL,
	[PersonalTitlePrefix] [nvarchar](75) NULL,
	[FirstName] [nvarchar](75) NOT NULL,
	[MiddleName] [nvarchar](75) NULL,
	[LastSurname] [nvarchar](75) NOT NULL,
	[GenerationCodeSuffix] [nvarchar](75) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentOtherName] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[OtherNameTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentParentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentParentAssociation](
	[StudentUSI] [int] NOT NULL,
	[ParentUSI] [int] NOT NULL,
	[RelationTypeId] [int] NULL,
	[PrimaryContactStatus] [bit] NULL,
	[LivesWith] [bit] NULL,
	[EmergencyContactStatus] [bit] NULL,
	[ContactPriority] [int] NULL,
	[ContactRestrictions] [nvarchar](250) NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentParentAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ParentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentParticipationCodeType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentParticipationCodeType](
	[StudentParticipationCodeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentParticipationCodeType] PRIMARY KEY CLUSTERED 
(
	[StudentParticipationCodeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentProgramAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentProgramAssociation](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[ReasonExitedDescriptorId] [int] NULL,
	[ServedOutsideOfRegularSession] [bit] NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentProgramAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC,
	[ProgramEducationOrganizationId] ASC,
	[BeginDate] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentProgramAssociationService]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentProgramAssociationService](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[ServiceDescriptorId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[PrimaryIndicator] [bit] NULL,
	[ServiceBeginDate] [date] NULL,
	[ServiceEndDate] [date] NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentProgramAssociationService] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramEducationOrganizationId] ASC,
	[BeginDate] ASC,
	[ServiceDescriptorId] ASC,
	[ProgramName] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentProgramAttendanceEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentProgramAttendanceEvent](
	[StudentUSI] [int] NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[EventDate] [date] NOT NULL,
	[AttendanceEventReason] [nvarchar](40) NULL,
	[AttendanceEventCategoryDescriptorId] [int] NOT NULL,
	[EducationalEnvironmentTypeId] [int] NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentProgramAttendanceEvent] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC,
	[ProgramEducationOrganizationId] ASC,
	[EventDate] ASC,
	[AttendanceEventCategoryDescriptorId] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentProgramParticipation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentProgramParticipation](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[DesignatedBy] [nvarchar](60) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentProgramParticipations] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentProgramParticipationProgramCharacteristic]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentProgramParticipationProgramCharacteristic](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramCharacteristicDescriptorId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentProgramParticipationProgramCharacteristic] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramCharacteristicDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentRace]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentRace](
	[StudentUSI] [int] NOT NULL,
	[RaceTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentRace] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[RaceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentSchoolAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentSchoolAssociation](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[SchoolYear] [smallint] NULL,
	[EntryDate] [date] NOT NULL,
	[EntryGradeLevelDescriptorId] [int] NOT NULL,
	[EntryGradeLevelReasonTypeId] [int] NULL,
	[EntryTypeDescriptorId] [int] NULL,
	[RepeatGradeIndicator] [bit] NULL,
	[SchoolChoiceTransfer] [bit] NULL,
	[ExitWithdrawDate] [date] NULL,
	[ExitWithdrawTypeDescriptorId] [int] NULL,
	[ResidencyStatusDescriptorId] [int] NULL,
	[PrimarySchool] [bit] NULL,
	[EmployedWhileEnrolled] [bit] NULL,
	[ClassOfSchoolYear] [smallint] NULL,
	[EducationOrganizationId] [int] NULL,
	[GraduationPlanTypeDescriptorId] [int] NULL,
	[GraduationSchoolYear] [smallint] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentSchoolAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[EntryDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentSchoolAssociationEducationPlan]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentSchoolAssociationEducationPlan](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[EntryDate] [date] NOT NULL,
	[EducationPlanTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentSchoolAssociationEducationPlans] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[EntryDate] ASC,
	[EducationPlanTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentSchoolAttendanceEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentSchoolAttendanceEvent](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[EventDate] [date] NOT NULL,
	[AttendanceEventCategoryDescriptorId] [int] NOT NULL,
	[AttendanceEventReason] [nvarchar](40) NULL,
	[EducationalEnvironmentTypeId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentSchoolAttendanceEvent] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[EventDate] ASC,
	[AttendanceEventCategoryDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentSectionAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentSectionAssociation](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[HomeroomIndicator] [bit] NULL,
	[RepeatIdentifierTypeId] [int] NULL,
	[TeacherStudentDataLinkExclusion] [bit] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentSectionAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[BeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentSectionAttendanceEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentSectionAttendanceEvent](
	[StudentUSI] [int] NOT NULL,
	[SchoolId] [int] NOT NULL,
	[ClassPeriodName] [nvarchar](20) NOT NULL,
	[ClassroomIdentificationCode] [nvarchar](20) NOT NULL,
	[LocalCourseCode] [nvarchar](60) NOT NULL,
	[TermTypeId] [int] NOT NULL,
	[SchoolYear] [smallint] NOT NULL,
	[EventDate] [date] NOT NULL,
	[AttendanceEventCategoryDescriptorId] [int] NOT NULL,
	[AttendanceEventReason] [nvarchar](40) NULL,
	[EducationalEnvironmentTypeId] [int] NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentSectionAttendanceEvent] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[ClassPeriodName] ASC,
	[ClassroomIdentificationCode] ASC,
	[LocalCourseCode] ASC,
	[TermTypeId] ASC,
	[SchoolYear] ASC,
	[EventDate] ASC,
	[AttendanceEventCategoryDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentSpecialEducationProgramAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentSpecialEducationProgramAssociation](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[IdeaEligibility] [bit] NULL,
	[SpecialEducationSettingDescriptorId] [int] NOT NULL,
	[SpecialEducationHoursPerWeek] [decimal](5, 2) NULL,
	[SchoolHoursPerWeek] [decimal](5, 2) NULL,
	[MultiplyDisabled] [bit] NULL,
	[MedicallyFragile] [bit] NULL,
	[LastEvaluationDate] [date] NULL,
	[IEPReviewDate] [date] NULL,
	[IEPBeginDate] [date] NULL,
	[IEPEndDate] [date] NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
 CONSTRAINT [PK_StudentSpecialEducationProgramAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC,
	[ProgramEducationOrganizationId] ASC,
	[BeginDate] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentSpecialEducationProgramAssociationServiceProvider]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentSpecialEducationProgramAssociationServiceProvider](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[StaffUSI] [int] NOT NULL,
	[PrimaryProvider] [bit] NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentSpecialEducationProgramAssociationServiceProvider] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramEducationOrganizationId] ASC,
	[BeginDate] ASC,
	[StaffUSI] ASC,
	[ProgramName] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentTelephone]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentTelephone](
	[StudentUSI] [int] NOT NULL,
	[TelephoneNumberTypeId] [int] NOT NULL,
	[OrderOfPriority] [int] NULL,
	[TextMessageCapabilityIndicator] [bit] NULL,
	[TelephoneNumber] [nvarchar](24) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentTelephone] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[TelephoneNumberTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentTitleIPartAProgramAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentTitleIPartAProgramAssociation](
	[StudentUSI] [int] NOT NULL,
	[ProgramTypeId] [int] NOT NULL,
	[ProgramEducationOrganizationId] [int] NOT NULL,
	[BeginDate] [date] NOT NULL,
	[TitleIPartAParticipantTypeId] [int] NOT NULL,
	[ProgramName] [nvarchar](60) NOT NULL,
	[EducationOrganizationId] [int] NOT NULL,
 CONSTRAINT [PK_StudentTitleIPartAProgramAssociation] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[ProgramTypeId] ASC,
	[ProgramName] ASC,
	[ProgramEducationOrganizationId] ASC,
	[BeginDate] ASC,
	[EducationOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[StudentVisa]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[StudentVisa](
	[StudentUSI] [int] NOT NULL,
	[VisaTypeId] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_StudentVisa] PRIMARY KEY CLUSTERED 
(
	[StudentUSI] ASC,
	[VisaTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[TeachingCredentialBasisType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[TeachingCredentialBasisType](
	[TeachingCredentialBasisTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TeachingCredentialBasisType] PRIMARY KEY CLUSTERED 
(
	[TeachingCredentialBasisTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[TeachingCredentialDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[TeachingCredentialDescriptor](
	[TeachingCredentialDescriptorId] [int] NOT NULL,
	[TeachingCredentialTypeId] [int] NULL,
 CONSTRAINT [PK_TeachingCredentialDescriptor] PRIMARY KEY CLUSTERED 
(
	[TeachingCredentialDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[TeachingCredentialType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[TeachingCredentialType](
	[TeachingCredentialTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TeachingCredentialType] PRIMARY KEY CLUSTERED 
(
	[TeachingCredentialTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[TelephoneNumberType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[TelephoneNumberType](
	[TelephoneNumberTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TelephoneNumberType] PRIMARY KEY CLUSTERED 
(
	[TelephoneNumberTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[TermType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[TermType](
	[TermTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TermType] PRIMARY KEY CLUSTERED 
(
	[TermTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[TitleIPartAParticipantType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[TitleIPartAParticipantType](
	[TitleIPartAParticipantTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TitleIPartAParticipantType] PRIMARY KEY CLUSTERED 
(
	[TitleIPartAParticipantTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[TitleIPartASchoolDesignationType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[TitleIPartASchoolDesignationType](
	[TitleIPartASchoolDesignationTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TitleIPartASchoolDesignationType] PRIMARY KEY CLUSTERED 
(
	[TitleIPartASchoolDesignationTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[VisaType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[VisaType](
	[VisaTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_VisaType] PRIMARY KEY CLUSTERED 
(
	[VisaTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[WeaponDescriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[WeaponDescriptor](
	[WeaponDescriptorId] [int] NOT NULL,
	[WeaponTypeId] [int] NULL,
 CONSTRAINT [PK_WeaponDescriptor] PRIMARY KEY CLUSTERED 
(
	[WeaponDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [edfi].[WeaponType]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edfi].[WeaponType](
	[WeaponTypeId] [int] IDENTITY(1,1) NOT NULL,
	[CodeValue] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
	[ShortDescription] [nvarchar](450) NOT NULL,
	[Id] [uniqueidentifier] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_WeaponsType] PRIMARY KEY CLUSTERED 
(
	[WeaponTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [util].[DashboardSchemaTable]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [util].[DashboardSchemaTable](
	[DashboardSchemaTableId] [int] IDENTITY(1,1) NOT NULL,
	[TableSchema] [nvarchar](255) NULL,
	[TableName] [nvarchar](255) NULL
)

GO
/****** Object:  Index [ci_azure_fixup_util_DashboardSchemaTable]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE CLUSTERED INDEX [ci_azure_fixup_util_DashboardSchemaTable] ON [util].[DashboardSchemaTable]
(
	[DashboardSchemaTableId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Table [util].[EdFiPopulation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [util].[EdFiPopulation](
	[EdFiPopulationId] [int] IDENTITY(1,1) NOT NULL,
	[TableSchema] [nvarchar](255) NULL,
	[TableName] [nvarchar](255) NULL,
	[RecordCount] [int] NULL,
	[PriorRecordCount] [int] NULL,
	[PercentChanged] [decimal](10, 2) NULL,
	[MostRecentDate] [date] NULL,
	[PriorMostRecentDate] [date] NULL,
	[DatabaseName] [nvarchar](255) NULL,
	[PriorDatabaseName] [nvarchar](255) NULL,
	[Comment] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[EdFiPopulationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [util].[EdFiSanity]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [util].[EdFiSanity](
	[EdFiSanityId] [int] IDENTITY(1,1) NOT NULL,
	[BeginLine] [int] NULL,
	[EndLine] [int] NULL,
	[InterChangeName] [nvarchar](255) NULL,
	[ScriptResult] [nvarchar](20) NULL,
	[ExpectedResult] [nvarchar](max) NULL,
	[ActualResult] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[Script] [nvarchar](max) NULL,
	[Operator] [char](2) NULL,
	[ExpectedNumber] [float] NULL,
	[ParserCompletionFlag] [bit] NULL,
	[ExecCompletionFlag] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[EdFiSanityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [util].[QAResults]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [util].[QAResults](
	[QAResultsId] [int] IDENTITY(1,1) NOT NULL,
	[ScriptFileName] [nvarchar](255) NULL,
	[ScriptResult] [nvarchar](20) NULL,
	[NumberOfDiscrepancies] [int] NULL,
	[Comment] [nvarchar](max) NULL,
	[ResultFileName] [nvarchar](255) NULL,
	[CreateDateTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[QAResultsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [util].[TeamCityStatistic]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [util].[TeamCityStatistic](
	[TeamCityStatisticId] [int] IDENTITY(1,1) NOT NULL,
	[StatisticKey] [nvarchar](255) NULL,
	[StatisticValue] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[TeamCityStatisticId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  View [auth].[EducationOrganizationToStaff_Assignment]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [auth].[EducationOrganizationToStaff_Assignment]
WITH SCHEMABINDING
AS
-- EdOrg to Staff (through assignment)
select	edorg.EducationOrganizationId, s.Id as StaffGuid, s.StaffUniqueId, assgn.BeginDate, assgn.EndDate, COUNT_BIG(*) as Count
from	edfi.EducationOrganization edorg
		inner join edfi.StaffEducationOrganizationAssignmentAssociation assgn
			on edorg.EducationOrganizationId = assgn.EducationOrganizationId
		inner join edfi.Staff s
			on assgn.StaffUSI = s.StaffUSI
group by s.Id, s.StaffUniqueId, edorg.EducationOrganizationId, BeginDate, EndDate

--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_EducationOrganizationToStaff_Assignment]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_EducationOrganizationToStaff_Assignment] ON [auth].[EducationOrganizationToStaff_Assignment]
(
	[StaffGuid] ASC,
	[EducationOrganizationId] ASC,
	[StaffUniqueId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[EducationOrganizationToStaff_Employment]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [auth].[EducationOrganizationToStaff_Employment]
WITH SCHEMABINDING
AS
-- EdOrg to Staff (through Employment)
select	edorg.EducationOrganizationId, s.Id as StaffGuid, s.StaffUniqueId, empl.HireDate as BeginDate, empl.EndDate, COUNT_BIG(*) as Count
from	edfi.EducationOrganization edorg
		inner join edfi.StaffEducationOrganizationEmploymentAssociation empl
			on edorg.EducationOrganizationId = empl.EducationOrganizationId
		inner join edfi.Staff s
			on empl.StaffUSI = s.StaffUSI
group by s.Id, s.StaffUniqueId, edorg.EducationOrganizationId, HireDate, EndDate

--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_EducationOrganizationToStaff_Employment]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_EducationOrganizationToStaff_Employment] ON [auth].[EducationOrganizationToStaff_Employment]
(
	[StaffGuid] ASC,
	[EducationOrganizationId] ASC,
	[StaffUniqueId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[LocalEducationAgencyIdToStaff]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [auth].[LocalEducationAgencyIdToStaff]
AS
-- LEA to Staff (through employment)
select	emp.EducationOrganizationId as LocalEducationAgencyId, null as SchoolId, emp.StaffGuid, emp.StaffUniqueId, BeginDate, EndDate
from	edfi.LocalEducationAgency lea
		inner join auth.EducationOrganizationToStaff_Employment emp
			on lea.LocalEducationAgencyId = emp.EducationOrganizationId
UNION ALL
-- LEA to Staff (through assignment)
select	assgn.EducationOrganizationId as LocalEducationAgencyId, null as SchoolId, assgn.StaffGuid, assgn.StaffUniqueId, BeginDate, EndDate
from	edfi.LocalEducationAgency lea
		inner join auth.EducationOrganizationToStaff_Assignment assgn
			on lea.LocalEducationAgencyId = assgn.EducationOrganizationId
UNION ALL
-- School to Staff (through employment)
select	sch.LocalEducationAgencyId, emp.EducationOrganizationId as SchoolId, emp.StaffGuid, emp.StaffUniqueId, BeginDate, EndDate
from	edfi.School sch
		inner join auth.EducationOrganizationToStaff_Employment emp
			on sch.SchoolId = emp.EducationOrganizationId
UNION ALL
-- School to Staff (through assignment)
select	sch.LocalEducationAgencyId, assgn.EducationOrganizationId as SchoolId, assgn.StaffGuid, assgn.StaffUniqueId, BeginDate, EndDate
from	edfi.School sch
		inner join auth.EducationOrganizationToStaff_Assignment assgn
			on sch.SchoolId = assgn.EducationOrganizationId
--

GO
/****** Object:  View [auth].[EducationOrganizationToStaffUSI_Assignment]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [auth].[EducationOrganizationToStaffUSI_Assignment]
WITH SCHEMABINDING
AS
-- EdOrg to Staff (through assignment)
select	edorg.EducationOrganizationId, assgn.StaffUSI, assgn.BeginDate, assgn.EndDate, COUNT_BIG(*) as Count
from	edfi.EducationOrganization edorg
		inner join edfi.StaffEducationOrganizationAssignmentAssociation assgn
			on edorg.EducationOrganizationId = assgn.EducationOrganizationId
group by assgn.StaffUSI, edorg.EducationOrganizationId, BeginDate, EndDate

--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_EducationOrganizationToStaffUSI_Assignment]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_EducationOrganizationToStaffUSI_Assignment] ON [auth].[EducationOrganizationToStaffUSI_Assignment]
(
	[StaffUSI] ASC,
	[EducationOrganizationId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[EducationOrganizationToStaffUSI_Employment]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [auth].[EducationOrganizationToStaffUSI_Employment]
WITH SCHEMABINDING
AS
-- EdOrg to Staff (through Employment)
select	edorg.EducationOrganizationId, empl.StaffUSI, empl.HireDate as BeginDate, empl.EndDate, COUNT_BIG(*) as Count
from	edfi.EducationOrganization edorg
		inner join edfi.StaffEducationOrganizationEmploymentAssociation empl
			on edorg.EducationOrganizationId = empl.EducationOrganizationId
group by empl.StaffUSI, edorg.EducationOrganizationId, HireDate, EndDate

--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_EducationOrganizationToStaffUSI_Employment]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_EducationOrganizationToStaffUSI_Employment] ON [auth].[EducationOrganizationToStaffUSI_Employment]
(
	[StaffUSI] ASC,
	[EducationOrganizationId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[LocalEducationAgencyIdToStaffUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[LocalEducationAgencyIdToStaffUSI]
AS
-- LEA to Staff (through employment)
select	emp.EducationOrganizationId as LocalEducationAgencyId, null as SchoolId, emp.StaffUSI, BeginDate, EndDate
from	edfi.LocalEducationAgency lea
		inner join auth.EducationOrganizationToStaffUSI_Employment emp
			on lea.LocalEducationAgencyId = emp.EducationOrganizationId
UNION ALL
-- LEA to Staff (through assignment)
select	assgn.EducationOrganizationId as LocalEducationAgencyId, null as SchoolId, assgn.StaffUSI, BeginDate, EndDate
from	edfi.LocalEducationAgency lea
		inner join auth.EducationOrganizationToStaffUSI_Assignment assgn
			on lea.LocalEducationAgencyId = assgn.EducationOrganizationId
UNION ALL
-- School to Staff (through employment)
select	sch.LocalEducationAgencyId, emp.EducationOrganizationId as SchoolId, emp.StaffUSI, BeginDate, EndDate
from	edfi.School sch
		inner join auth.EducationOrganizationToStaffUSI_Employment emp
			on sch.SchoolId = emp.EducationOrganizationId
UNION ALL
-- School to Staff (through assignment)
select	sch.LocalEducationAgencyId, assgn.EducationOrganizationId as SchoolId, assgn.StaffUSI, BeginDate, EndDate
from	edfi.School sch
		inner join auth.EducationOrganizationToStaffUSI_Assignment assgn
			on sch.SchoolId = assgn.EducationOrganizationId
--

GO
/****** Object:  View [auth].[SchoolIdToStaff]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[SchoolIdToStaff]
AS
-- School to Staff (through employment)
select	sch.SchoolId, emp.StaffGuid, emp.StaffUniqueId, BeginDate, EndDate
from	edfi.School sch
		inner join auth.EducationOrganizationToStaff_Employment emp
			on sch.SchoolId = emp.EducationOrganizationId
UNION ALL
-- School to Staff (through assignment)
select	sch.SchoolId, assgn.StaffGuid, assgn.StaffUniqueId, BeginDate, EndDate
from	edfi.School sch
		inner join auth.EducationOrganizationToStaff_Assignment assgn
			on sch.SchoolId = assgn.EducationOrganizationId
--

GO
/****** Object:  View [auth].[LocalEducationAgency]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[LocalEducationAgency]
WITH SCHEMABINDING
AS
	select	Id, LocalEducationAgencyId 
	from	edfi.LocalEducationAgency lea
			inner join edfi.EducationOrganization edorg
				on edorg.EducationOrganizationId = lea.LocalEducationAgencyId
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_LocalEducationAgency]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_LocalEducationAgency] ON [auth].[LocalEducationAgency]
(
	[Id] ASC,
	[LocalEducationAgencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[LocalEducationAgencyIdToParent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[LocalEducationAgencyIdToParent]
WITH SCHEMABINDING
AS
-- LEA to Parent Guid
select	sch.LocalEducationAgencyId, p.Id as ParentGuid, p.ParentUniqueId, ssa.EntryDate as BeginDate, ssa.ExitWithdrawDate as EndDate, COUNT_BIG(*) as Count 
from	edfi.School sch
		inner join edfi.StudentSchoolAssociation ssa
			on sch.SchoolId = ssa.SchoolId
		inner join edfi.Student s
			on ssa.StudentUSI = s.StudentUSI
		inner join edfi.StudentParentAssociation spa
			on ssa.StudentUSI = spa.StudentUSI
		inner join edfi.Parent p
			on spa.ParentUSI = p.ParentUSI
group by p.Id, LocalEducationAgencyId, p.ParentUniqueId, EntryDate, ExitWithdrawDate
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_LocalEducationAgencyIdToParent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_LocalEducationAgencyIdToParent] ON [auth].[LocalEducationAgencyIdToParent]
(
	[ParentGuid] ASC,
	[LocalEducationAgencyId] ASC,
	[ParentUniqueId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[LocalEducationAgencyIdToParentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[LocalEducationAgencyIdToParentUSI]
WITH SCHEMABINDING
AS
-- LEA to Parent USI
select	sch.LocalEducationAgencyId, spa.ParentUSI, ssa.EntryDate as BeginDate, ssa.ExitWithdrawDate as EndDate, COUNT_BIG(*) as Count
from	edfi.School sch
		inner join edfi.StudentSchoolAssociation ssa
			on sch.SchoolId = ssa.SchoolId
		inner join edfi.Student s
			on ssa.StudentUSI = s.StudentUSI
		inner join edfi.StudentParentAssociation spa
			on ssa.StudentUSI = spa.StudentUSI
group by spa.ParentUSI, LocalEducationAgencyId, ssa.EntryDate, ssa.ExitWithdrawDate 
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_LocalEducationAgencyIdToParentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_LocalEducationAgencyIdToParentUSI] ON [auth].[LocalEducationAgencyIdToParentUSI]
(
	[ParentUSI] ASC,
	[LocalEducationAgencyId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[LocalEducationAgencyIdToSchoolGuid]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[LocalEducationAgencyIdToSchoolGuid]
WITH SCHEMABINDING
AS
-- LEA to School Guid (SchoolId could be included here, but requires a join and is less direct than the view below)
select	sch.LocalEducationAgencyId, edorg_sch.Id as SchoolGuid --, sch.SchoolId
from	edfi.School sch
		inner join edfi.EducationOrganization edorg_sch
			on sch.SchoolId = edorg_sch.EducationOrganizationId
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_LocalEducationAgencyIdToSchoolGuid]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_LocalEducationAgencyIdToSchoolGuid] ON [auth].[LocalEducationAgencyIdToSchoolGuid]
(
	[SchoolGuid] ASC,
	[LocalEducationAgencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[LocalEducationAgencyIdToSchoolId]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[LocalEducationAgencyIdToSchoolId]
--WITH SCHEMABINDING
AS
-- LEA to School
select	LocalEducationAgencyId, SchoolId 
from	edfi.School sch
--

GO
/****** Object:  View [auth].[LocalEducationAgencyIdToStudent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- LEA to Student
CREATE VIEW [auth].[LocalEducationAgencyIdToStudent]
WITH SCHEMABINDING
AS
select    LocalEducationAgencyId, s.Id as StudentGuid, s.StudentUniqueId, ssa.EntryDate as BeginDate, ssa.ExitWithdrawDate as EndDate, COUNT_BIG(*) as Ignored
from    edfi.School sch
        inner join edfi.StudentSchoolAssociation ssa
            on sch.SchoolId = ssa.SchoolId
        inner join edfi.Student s
            on ssa.StudentUSI = s.StudentUSI
group by LocalEducationAgencyId, s.Id, s.StudentUniqueId, ssa.EntryDate, ssa.ExitWithdrawDate
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_LocalEducationAgencyIdToStudent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_LocalEducationAgencyIdToStudent] ON [auth].[LocalEducationAgencyIdToStudent]
(
	[StudentGuid] ASC,
	[LocalEducationAgencyId] ASC,
	[StudentUniqueId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[LocalEducationAgencyIdToStudentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[LocalEducationAgencyIdToStudentUSI]
WITH SCHEMABINDING
AS
-- LEA to Student GUID
select sch.LocalEducationAgencyId, ssa.StudentUSI, ssa.EntryDate as BeginDate, ssa.ExitWithdrawDate as EndDate, COUNT_BIG(*) as Ignored
from   edfi.School sch
              inner join edfi.StudentSchoolAssociation ssa
                     on sch.SchoolId = ssa.SchoolId
group by sch.LocalEducationAgencyId, ssa.StudentUSI, ssa.EntryDate, ssa.ExitWithdrawDate
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_LocalEducationAgencyToStudentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_LocalEducationAgencyToStudentUSI] ON [auth].[LocalEducationAgencyIdToStudentUSI]
(
	[StudentUSI] ASC,
	[LocalEducationAgencyId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[ParentToStudent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [auth].[ParentToStudent]
WITH SCHEMABINDING
AS
select	s.Id as StudentGuid, s.StudentUniqueId, p.Id as ParentGuid, p.ParentUniqueId
from	edfi.Student s
		inner join edfi.StudentParentAssociation spa
			on s.StudentUSI = spa.StudentUSI
		inner join edfi.Parent p
			on spa.ParentUSI = p.ParentUSI
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_ParentToStudent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_ParentToStudent] ON [auth].[ParentToStudent]
(
	[StudentUniqueId] ASC,
	[ParentUniqueId] ASC,
	[StudentGuid] ASC,
	[ParentGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[ParentUSIToStudentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[ParentUSIToStudentUSI]
WITH SCHEMABINDING
AS
select	spa.StudentUSI, spa.ParentUSI
from	edfi.StudentParentAssociation spa

--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_ParentUSIToStudentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_ParentUSIToStudentUSI] ON [auth].[ParentUSIToStudentUSI]
(
	[StudentUSI] ASC,
	[ParentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[School]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[School]
WITH SCHEMABINDING
AS
	select	Id, SchoolId, LocalEducationAgencyId
	from	edfi.School sch
			inner join edfi.EducationOrganization edorg
				on edorg.EducationOrganizationId = sch.SchoolId
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_School]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_School] ON [auth].[School]
(
	[Id] ASC,
	[SchoolId] ASC,
	[LocalEducationAgencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[SchoolIdToStaffUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[SchoolIdToStaffUSI]
AS
-- School to Staff (through employment)
select	sch.SchoolId, seo_empl.StaffUSI, HireDate as BeginDate, EndDate
from	edfi.School sch
		inner join edfi.StaffEducationOrganizationEmploymentAssociation seo_empl
			on sch.SchoolId = seo_empl.EducationOrganizationId
UNION ALL
-- School to Staff (through assignment)
select	sch.SchoolId, seo_assgn.StaffUSI, BeginDate, EndDate
from	edfi.School sch
		inner join edfi.StaffEducationOrganizationAssignmentAssociation seo_assgn
			on sch.SchoolId = seo_assgn.EducationOrganizationId
--

GO
/****** Object:  View [auth].[SchoolIdToStudent]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [auth].[SchoolIdToStudent]
WITH SCHEMABINDING
AS
-- LEA to Student
select	SchoolId, s.Id as StudentGuid, s.StudentUniqueId, ssa.EntryDate as BeginDate, ssa.ExitWithdrawDate as EndDate
from	edfi.StudentSchoolAssociation ssa
		inner join edfi.Student s
			on ssa.StudentUSI = s.StudentUSI
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_SchoolIdToStudent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_SchoolIdToStudent] ON [auth].[SchoolIdToStudent]
(
	[StudentGuid] ASC,
	[SchoolId] ASC,
	[StudentUniqueId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [auth].[SchoolIdToStudentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [auth].[SchoolIdToStudentUSI]
WITH SCHEMABINDING
AS
-- LEA to Student GUID
select	ssa.SchoolId, ssa.StudentUSI, ssa.EntryDate as BeginDate, ssa.ExitWithdrawDate as EndDate
from	edfi.StudentSchoolAssociation ssa
--

GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UCIX_SchoolIdToStudentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE CLUSTERED INDEX [UCIX_SchoolIdToStudentUSI] ON [auth].[SchoolIdToStudentUSI]
(
	[StudentUSI] ASC,
	[SchoolId] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  View [edfi].[CurrentStaffEducationOrgAssignmentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [edfi].[CurrentStaffEducationOrgAssignmentAssociation] AS
SELECT *
FROM   edfi.StaffEducationOrganizationAssignmentAssociation SSA
WHERE (EndDate IS NULL)
                or (SSA.EndDate >= (select MAX(CD.Date) 
                                    from edfi.CalendarDate CD 
                                    where SSA.EducationOrganizationId = CD.EducationOrganizationId)
                                ) 
                or (SSA.EndDate >= (select MAX(Att.EventDate) 
                                    from edfi.StudentSectionAttendanceEvent Att)
                                )
--

GO
/****** Object:  View [edfi].[CurrentStaffEducationOrgEmploymentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [edfi].[CurrentStaffEducationOrgEmploymentAssociation] AS
SELECT *
FROM   edfi.StaffEducationOrganizationEmploymentAssociation SSA
WHERE (EndDate IS NULL)
                or (SSA.EndDate >= (select MAX(CD.Date) 
                                    from edfi.CalendarDate CD 
                                    where SSA.EducationOrganizationId = CD.EducationOrganizationId)
                                ) 
                or (SSA.EndDate >= (select MAX(Att.EventDate) 
                                    from edfi.StudentSectionAttendanceEvent Att)
                                )
--

GO
/****** Object:  View [edfi].[MinMaxDate]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [edfi].[MinMaxDate]
AS
SELECT Sch.SchoolId
		,ISNULL(MAX(Att.MaxDate), Getdate())as MaxDate
		,ISNULL(Min(Att.MinDate),'1900/1/1')as MinDate
		,ISNULL(Min(Att.SessionEndDate),'1900/1/1')as SessionEndDate
FROM edfi.School Sch
Left outer join
(
			SELECT   a.SchoolId,
				MAX(a.EventDate) as MaxDate,
				MIN(b.BeginDate) as MinDate, 
				Min(b.EndDate) as SessionEndDate
			FROM edfi.StudentSectionAttendanceEvent a
				Join edfi.Session b
					On a. SchoolId = b.SchoolId
			Group By  a.SchoolId
			Union All
			
			SELECT   a.SchoolId,
				MAX(a.EventDate) as MaxDate,
				MIN(b.BeginDate) as MinDate,
				Min(b.EndDate) as SessionEndDate
			FROM edfi.StudentSchoolAttendanceEvent a
				Join edfi.Session b
					On a. SchoolId = b.SchoolId
			Group By  a.SchoolId
		)Att
		on Sch.SchoolId = Att.SchoolId
Group by sch.SchoolId

--

GO
/****** Object:  View [edfi].[SchoolList]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [edfi].[SchoolList]
AS
 SELECT DISTINCT b.LocalEducationAgencyId, a.SchoolId
FROM 
	edfi.Grade a INNER JOIN
	edfi.School b
		ON a.SchoolId = b.SchoolId

--

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AcademicHonorCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AcademicHonorCategoryType_ShortDescription] ON [edfi].[AcademicHonorCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AcademicHonorCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AcademicHonorCategoryType] ON [edfi].[AcademicHonorCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AcademicSubjectType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AcademicSubjectType_ShortDescription] ON [edfi].[AcademicSubjectType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AcademicSubjectType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AcademicSubjectType] ON [edfi].[AcademicSubjectType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AcademicWeek]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AcademicWeek] ON [edfi].[AcademicWeek]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AccommodationType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AccommodationType_ShortDescription] ON [edfi].[AccommodationType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AccommodationType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AccommodationType] ON [edfi].[AccommodationType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Account]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Account] ON [edfi].[Account]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AccountabilityRating]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AccountabilityRating] ON [edfi].[AccountabilityRating]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AchievementCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AchievementCategoryType_ShortDescription] ON [edfi].[AchievementCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AchievementCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AchievementCategoryType] ON [edfi].[AchievementCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Actual]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Actual] ON [edfi].[Actual]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AdditionalCreditType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AdditionalCreditType_ShortDescription] ON [edfi].[AdditionalCreditType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AdditionalCreditType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AdditionalCreditType] ON [edfi].[AdditionalCreditType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AddressType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AddressType_ShortDescription] ON [edfi].[AddressType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AddressType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AddressType] ON [edfi].[AddressType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AdministrationEnvironmentType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AdministrationEnvironmentType_ShortDescription] ON [edfi].[AdministrationEnvironmentType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AdministrationEnvironmentType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AdministrationEnvironmentType] ON [edfi].[AdministrationEnvironmentType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AdministrativeFundingControlType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AdministrativeFundingControlType_ShortDescription] ON [edfi].[AdministrativeFundingControlType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AdministrativeFundingControlType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AdministrativeFundingControlType] ON [edfi].[AdministrativeFundingControlType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Assessment]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Assessment] ON [edfi].[Assessment]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AssessmentCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AssessmentCategoryType_ShortDescription] ON [edfi].[AssessmentCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AssessmentCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AssessmentCategoryType] ON [edfi].[AssessmentCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AssessmentFamily]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AssessmentFamily] ON [edfi].[AssessmentFamily]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AssessmentIdentificationSystemType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AssessmentIdentificationSystemType_ShortDescription] ON [edfi].[AssessmentIdentificationSystemType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AssessmentIdentificationSystemType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AssessmentIdentificationSystemType] ON [edfi].[AssessmentIdentificationSystemType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AssessmentItem]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AssessmentItem] ON [edfi].[AssessmentItem]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_AssessmentItem_Item]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentItem_Item] ON [edfi].[AssessmentItem]
(
	[Version] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[IdentificationCode] ASC,
	[AssessmentTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AssessmentItemCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AssessmentItemCategoryType_ShortDescription] ON [edfi].[AssessmentItemCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AssessmentItemCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AssessmentItemCategoryType] ON [edfi].[AssessmentItemCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_AssessmentItemLearningStandard_LearningStandardId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentItemLearningStandard_LearningStandardId] ON [edfi].[AssessmentItemLearningStandard]
(
	[LearningStandardId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AssessmentItemResultType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AssessmentItemResultType_ShortDescription] ON [edfi].[AssessmentItemResultType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AssessmentItemResultType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AssessmentItemResultType] ON [edfi].[AssessmentItemResultType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AssessmentReportingMethodType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AssessmentReportingMethodType_ShortDescription] ON [edfi].[AssessmentReportingMethodType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AssessmentReportingMethodType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AssessmentReportingMethodType] ON [edfi].[AssessmentReportingMethodType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_AttendanceEventCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_AttendanceEventCategoryType_ShortDescription] ON [edfi].[AttendanceEventCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_AttendanceEventCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_AttendanceEventCategoryType] ON [edfi].[AttendanceEventCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_BehaviorType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_BehaviorType_ShortDescription] ON [edfi].[BehaviorType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_BehaviorType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_BehaviorType] ON [edfi].[BehaviorType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_BellSchedule]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_BellSchedule] ON [edfi].[BellSchedule]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Budget]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Budget] ON [edfi].[Budget]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CalendarDate]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CalendarDate] ON [edfi].[CalendarDate]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CalendarEventType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CalendarEventType_ShortDescription] ON [edfi].[CalendarEventType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CalendarEventType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CalendarEventType] ON [edfi].[CalendarEventType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CareerPathwayType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CareerPathwayType_ShortDescription] ON [edfi].[CareerPathwayType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CareerPathwayType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CareerPathwayType] ON [edfi].[CareerPathwayType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CharterStatusType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CharterStatusType_ShortDescription] ON [edfi].[CharterStatusType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CharterStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CharterStatusType] ON [edfi].[CharterStatusType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CitizenshipStatusType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CitizenshipStatusType_ShortDescription] ON [edfi].[CitizenshipStatusType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CitizenshipStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CitizenshipStatusType] ON [edfi].[CitizenshipStatusType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ClassPeriod]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ClassPeriod] ON [edfi].[ClassPeriod]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ClassroomPositionType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ClassroomPositionType_ShortDescription] ON [edfi].[ClassroomPositionType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ClassroomPositionType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ClassroomPositionType] ON [edfi].[ClassroomPositionType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Cohort]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Cohort] ON [edfi].[Cohort]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CohortScopeType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CohortScopeType_ShortDescription] ON [edfi].[CohortScopeType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CohortScopeType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CohortScopeType] ON [edfi].[CohortScopeType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CohortType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CohortType_ShortDescription] ON [edfi].[CohortType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CohortType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CohortType] ON [edfi].[CohortType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CohortYearType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CohortYearType_ShortDescription] ON [edfi].[CohortYearType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CohortYearType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CohortYearType] ON [edfi].[CohortYearType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CompetencyObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CompetencyObjective] ON [edfi].[CompetencyObjective]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ContentClassType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ContentClassType_ShortDescription] ON [edfi].[ContentClassType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ContentClassType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ContentClassType] ON [edfi].[ContentClassType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ContinuationOfServicesReasonType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ContinuationOfServicesReasonType_ShortDescription] ON [edfi].[ContinuationOfServicesReasonType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ContinuationOfServicesReasonType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ContinuationOfServicesReasonType] ON [edfi].[ContinuationOfServicesReasonType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ContractedStaff]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ContractedStaff] ON [edfi].[ContractedStaff]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CostRateType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CostRateType_ShortDescription] ON [edfi].[CostRateType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CostRateType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CostRateType] ON [edfi].[CostRateType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CountryCodeType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CountryCodeType_ShortDescription] ON [edfi].[CountryCodeType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CountryCodeType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CountryCodeType] ON [edfi].[CountryCodeType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CountryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CountryType_ShortDescription] ON [edfi].[CountryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CountryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CountryType] ON [edfi].[CountryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Course]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Course] ON [edfi].[Course]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Course_IdentyCrseCdEdOrgIdSubjAreaTypeId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_Course_IdentyCrseCdEdOrgIdSubjAreaTypeId] ON [edfi].[Course]
(
	[CourseCode] ASC,
	[EducationOrganizationId] ASC,
	[AcademicSubjectDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CourseAttemptResultType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CourseAttemptResultType_ShortDescription] ON [edfi].[CourseAttemptResultType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CourseAttemptResultType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CourseAttemptResultType] ON [edfi].[CourseAttemptResultType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CourseCodeSystemType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CourseCodeSystemType_ShortDescription] ON [edfi].[CourseCodeSystemType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CourseCodeSystemType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CourseCodeSystemType] ON [edfi].[CourseCodeSystemType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CourseDefinedByType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CourseDefinedByType_ShortDescription] ON [edfi].[CourseDefinedByType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CourseDefinedByType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CourseDefinedByType] ON [edfi].[CourseDefinedByType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CourseGPAApplicabilityType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CourseGPAApplicabilityType_ShortDescription] ON [edfi].[CourseGPAApplicabilityType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CourseGPAApplicabilityType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CourseGPAApplicabilityType] ON [edfi].[CourseGPAApplicabilityType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CourseLevelCharacteristicType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CourseLevelCharacteristicType_ShortDescription] ON [edfi].[CourseLevelCharacteristicType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CourseLevelCharacteristicType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CourseLevelCharacteristicType] ON [edfi].[CourseLevelCharacteristicType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CourseOffering]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CourseOffering] ON [edfi].[CourseOffering]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CourseRepeatCodeType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CourseRepeatCodeType_ShortDescription] ON [edfi].[CourseRepeatCodeType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CourseRepeatCodeType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CourseRepeatCodeType] ON [edfi].[CourseRepeatCodeType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CourseTranscript]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CourseTranscript] ON [edfi].[CourseTranscript]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CredentialType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CredentialType_ShortDescription] ON [edfi].[CredentialType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CredentialType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CredentialType] ON [edfi].[CredentialType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CreditType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CreditType_ShortDescription] ON [edfi].[CreditType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CreditType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CreditType] ON [edfi].[CreditType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_CurriculumUsedType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_CurriculumUsedType_ShortDescription] ON [edfi].[CurriculumUsedType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_CurriculumUsedType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_CurriculumUsedType] ON [edfi].[CurriculumUsedType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_DeliveryMethodType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_DeliveryMethodType_ShortDescription] ON [edfi].[DeliveryMethodType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DeliveryMethodType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DeliveryMethodType] ON [edfi].[DeliveryMethodType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Descriptor]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Descriptor] ON [edfi].[Descriptor]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_DiagnosisType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_DiagnosisType_ShortDescription] ON [edfi].[DiagnosisType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DiagnosisType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DiagnosisType] ON [edfi].[DiagnosisType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_DiplomaLevelType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_DiplomaLevelType_ShortDescription] ON [edfi].[DiplomaLevelType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DiplomaLevelType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DiplomaLevelType] ON [edfi].[DiplomaLevelType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_DiplomaType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_DiplomaType_ShortDescription] ON [edfi].[DiplomaType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DiplomaType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DiplomaType] ON [edfi].[DiplomaType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_DisabilityCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_DisabilityCategoryType_ShortDescription] ON [edfi].[DisabilityCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DisabilityCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DisabilityCategoryType] ON [edfi].[DisabilityCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_DisabilityType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_DisabilityType_ShortDescription] ON [edfi].[DisabilityType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DisabilityType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DisabilityType] ON [edfi].[DisabilityType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DisciplineAction]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DisciplineAction] ON [edfi].[DisciplineAction]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_DisciplineActionLengthDifferenceReasonType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_DisciplineActionLengthDifferenceReasonType_ShortDescription] ON [edfi].[DisciplineActionLengthDifferenceReasonType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DisciplineActionLengthDifferenceReasonType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DisciplineActionLengthDifferenceReasonType] ON [edfi].[DisciplineActionLengthDifferenceReasonType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DisciplineIncident]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DisciplineIncident] ON [edfi].[DisciplineIncident]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_DisciplineType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_DisciplineType_ShortDescription] ON [edfi].[DisciplineType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_DisciplineType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_DisciplineType] ON [edfi].[DisciplineType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_EducationalEnvironmentType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_EducationalEnvironmentType_ShortDescription] ON [edfi].[EducationalEnvironmentType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EducationalEnvironmentType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EducationalEnvironmentType] ON [edfi].[EducationalEnvironmentType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EducationContent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EducationContent] ON [edfi].[EducationContent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EducationOrganization]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EducationOrganization] ON [edfi].[EducationOrganization]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_EducationOrganizationCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_EducationOrganizationCategoryType_ShortDescription] ON [edfi].[EducationOrganizationCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EducationOrganizationCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EducationOrganizationCategoryType] ON [edfi].[EducationOrganizationCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_EducationOrganizationIdentificationSystemType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_EducationOrganizationIdentificationSystemType_ShortDescription] ON [edfi].[EducationOrganizationIdentificationSystemType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EducationOrganizationIdentificationSystemType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EducationOrganizationIdentificationSystemType] ON [edfi].[EducationOrganizationIdentificationSystemType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EducationOrganizationInterventionPrescriptionAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EducationOrganizationInterventionPrescriptionAssociation] ON [edfi].[EducationOrganizationInterventionPrescriptionAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EducationOrganizationNetworkAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EducationOrganizationNetworkAssociation] ON [edfi].[EducationOrganizationNetworkAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EducationOrganizationPeerAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EducationOrganizationPeerAssociation] ON [edfi].[EducationOrganizationPeerAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_EducationPlanType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_EducationPlanType_ShortDescription] ON [edfi].[EducationPlanType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EducationPlanType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EducationPlanType] ON [edfi].[EducationPlanType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ElectronicMailType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ElectronicMailType_ShortDescription] ON [edfi].[ElectronicMailType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ElectronicMailType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ElectronicMailType] ON [edfi].[ElectronicMailType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_EmploymentStatusType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_EmploymentStatusType_ShortDescription] ON [edfi].[EmploymentStatusType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EmploymentStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EmploymentStatusType] ON [edfi].[EmploymentStatusType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_EntryGradeLevelReasonType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_EntryGradeLevelReasonType_ShortDescription] ON [edfi].[EntryGradeLevelReasonType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EntryGradeLevelReasonType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EntryGradeLevelReasonType] ON [edfi].[EntryGradeLevelReasonType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_EntryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_EntryType_ShortDescription] ON [edfi].[EntryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EntryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EntryType] ON [edfi].[EntryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_EventCircumstanceType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_EventCircumstanceType_ShortDescription] ON [edfi].[EventCircumstanceType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_EventCircumstanceType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_EventCircumstanceType] ON [edfi].[EventCircumstanceType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ExitWithdrawType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ExitWithdrawType_ShortDescription] ON [edfi].[ExitWithdrawType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ExitWithdrawType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ExitWithdrawType] ON [edfi].[ExitWithdrawType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_FeederSchoolAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_FeederSchoolAssociation] ON [edfi].[FeederSchoolAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Grade]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Grade] ON [edfi].[Grade]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_GradebookEntry]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_GradebookEntry] ON [edfi].[GradebookEntry]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_GradebookEntryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_GradebookEntryType_ShortDescription] ON [edfi].[GradebookEntryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_GradebookEntryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_GradebookEntryType] ON [edfi].[GradebookEntryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_GradeLevelType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_GradeLevelType_ShortDescription] ON [edfi].[GradeLevelType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_GradeLevelType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_GradeLevelType] ON [edfi].[GradeLevelType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_GradeType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_GradeType_ShortDescription] ON [edfi].[GradeType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_GradeType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_GradeType] ON [edfi].[GradeType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_GradingPeriod]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_GradingPeriod] ON [edfi].[GradingPeriod]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_GradingPeriod_Type]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_GradingPeriod_Type] ON [edfi].[GradingPeriod]
(
	[EducationOrganizationId] ASC,
	[GradingPeriodDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_GradingPeriodType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_GradingPeriodType_ShortDescription] ON [edfi].[GradingPeriodType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_GradingPeriodType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_GradingPeriodType] ON [edfi].[GradingPeriodType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_GraduationPlan]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_GraduationPlan] ON [edfi].[GraduationPlan]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_GraduationPlanType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_GraduationPlanType_ShortDescription] ON [edfi].[GraduationPlanType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_GraduationPlanType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_GraduationPlanType] ON [edfi].[GraduationPlanType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_GunFreeSchoolsActReportingStatusType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_GunFreeSchoolsActReportingStatusType_ShortDescription] ON [edfi].[GunFreeSchoolsActReportingStatusType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_GunFreeSchoolsActReportingStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_GunFreeSchoolsActReportingStatusType] ON [edfi].[GunFreeSchoolsActReportingStatusType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_IdentificationDocumentUseType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_IdentificationDocumentUseType_ShortDescription] ON [edfi].[IdentificationDocumentUseType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_IdentificationDocumentUseType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_IdentificationDocumentUseType] ON [edfi].[IdentificationDocumentUseType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_IncidentLocationType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_IncidentLocationType_ShortDescription] ON [edfi].[IncidentLocationType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_IncidentLocationType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_IncidentLocationType] ON [edfi].[IncidentLocationType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_InstitutionTelephoneNumberType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_InstitutionTelephoneNumberType_ShortDescription] ON [edfi].[InstitutionTelephoneNumberType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_InstitutionTelephoneNumberType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_InstitutionTelephoneNumberType] ON [edfi].[InstitutionTelephoneNumberType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_IntegratedTechnologyStatusType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_IntegratedTechnologyStatusType_ShortDescription] ON [edfi].[IntegratedTechnologyStatusType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_IntegratedTechnologyStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_IntegratedTechnologyStatusType] ON [edfi].[IntegratedTechnologyStatusType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_InteractivityStyleType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_InteractivityStyleType_ShortDescription] ON [edfi].[InteractivityStyleType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_InteractivityStyleType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_InteractivityStyleType] ON [edfi].[InteractivityStyleType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_InternetAccessType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_InternetAccessType_ShortDescription] ON [edfi].[InternetAccessType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_InternetAccessType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_InternetAccessType] ON [edfi].[InternetAccessType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Intervention]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Intervention] ON [edfi].[Intervention]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_InterventionClassType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_InterventionClassType_ShortDescription] ON [edfi].[InterventionClassType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_InterventionClassType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_InterventionClassType] ON [edfi].[InterventionClassType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_InterventionEffectivenessRatingType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_InterventionEffectivenessRatingType_ShortDescription] ON [edfi].[InterventionEffectivenessRatingType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_InterventionEffectivenessRatingType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_InterventionEffectivenessRatingType] ON [edfi].[InterventionEffectivenessRatingType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_InterventionPrescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_InterventionPrescription] ON [edfi].[InterventionPrescription]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_InterventionStudy]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_InterventionStudy] ON [edfi].[InterventionStudy]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_LanguageType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_LanguageType_ShortDescription] ON [edfi].[LanguageType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LanguageType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LanguageType] ON [edfi].[LanguageType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_LanguageUseType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_LanguageUseType_ShortDescription] ON [edfi].[LanguageUseType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LanguageUseType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LanguageUseType] ON [edfi].[LanguageUseType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LearningObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LearningObjective] ON [edfi].[LearningObjective]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LearningStandard]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LearningStandard] ON [edfi].[LearningStandard]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LeaveEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LeaveEvent] ON [edfi].[LeaveEvent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_LeaveEventCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_LeaveEventCategoryType_ShortDescription] ON [edfi].[LeaveEventCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LeaveEventCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LeaveEventCategoryType] ON [edfi].[LeaveEventCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_LevelOfEducationType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_LevelOfEducationType_ShortDescription] ON [edfi].[LevelOfEducationType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LevelOfEducationType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LevelOfEducationType] ON [edfi].[LevelOfEducationType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_LimitedEnglishProficiencyType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_LimitedEnglishProficiencyType_ShortDescription] ON [edfi].[LimitedEnglishProficiencyType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LimitedEnglishProficiencyType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LimitedEnglishProficiencyType] ON [edfi].[LimitedEnglishProficiencyType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_LocalEducationAgencyCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_LocalEducationAgencyCategoryType_ShortDescription] ON [edfi].[LocalEducationAgencyCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LocalEducationAgencyCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LocalEducationAgencyCategoryType] ON [edfi].[LocalEducationAgencyCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_LocalEducationAgencyFederalFunds]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_LocalEducationAgencyFederalFunds] ON [edfi].[LocalEducationAgencyFederalFunds]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Location]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Location] ON [edfi].[Location]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_MagnetSpecialProgramEmphasisSchoolType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_MagnetSpecialProgramEmphasisSchoolType_ShortDescription] ON [edfi].[MagnetSpecialProgramEmphasisSchoolType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_MagnetSpecialProgramEmphasisSchoolType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_MagnetSpecialProgramEmphasisSchoolType] ON [edfi].[MagnetSpecialProgramEmphasisSchoolType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_MediumOfInstructionType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_MediumOfInstructionType_ShortDescription] ON [edfi].[MediumOfInstructionType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_MediumOfInstructionType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_MediumOfInstructionType] ON [edfi].[MediumOfInstructionType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_MeetingDayType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_MeetingDayType_ShortDescription] ON [edfi].[MeetingDayType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_MeetingDayType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_MeetingDayType] ON [edfi].[MeetingDayType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_MethodCreditEarnedType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_MethodCreditEarnedType_ShortDescription] ON [edfi].[MethodCreditEarnedType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_MethodCreditEarnedType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_MethodCreditEarnedType] ON [edfi].[MethodCreditEarnedType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_NetworkPurposeType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_NetworkPurposeType_ShortDescription] ON [edfi].[NetworkPurposeType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_NetworkPurposeType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_NetworkPurposeType] ON [edfi].[NetworkPurposeType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ObjectiveAssessment]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ObjectiveAssessment] ON [edfi].[ObjectiveAssessment]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_OldEthnicityType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_OldEthnicityType_ShortDescription] ON [edfi].[OldEthnicityType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_OldEthnicityType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_OldEthnicityType] ON [edfi].[OldEthnicityType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_OpenStaffPosition]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_OpenStaffPosition] ON [edfi].[OpenStaffPosition]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_OperationalStatusType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_OperationalStatusType_ShortDescription] ON [edfi].[OperationalStatusType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_OperationalStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_OperationalStatusType] ON [edfi].[OperationalStatusType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_OtherNameType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_OtherNameType_ShortDescription] ON [edfi].[OtherNameType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_OtherNameType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_OtherNameType] ON [edfi].[OtherNameType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Parent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Parent] ON [edfi].[Parent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UI_Parent_ParentUniqueId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_Parent_ParentUniqueId] ON [edfi].[Parent]
(
	[ParentUniqueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Payroll]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Payroll] ON [edfi].[Payroll]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_PerformanceBaseConversionType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_PerformanceBaseConversionType_ShortDescription] ON [edfi].[PerformanceBaseConversionType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_PerformanceBaseConversionType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_PerformanceBaseConversionType] ON [edfi].[PerformanceBaseConversionType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_PersonalInformationVerificationType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_PersonalInformationVerificationType_ShortDescription] ON [edfi].[PersonalInformationVerificationType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_PersonalInformationVerificationType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_PersonalInformationVerificationType] ON [edfi].[PersonalInformationVerificationType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_PopulationServedType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_PopulationServedType_ShortDescription] ON [edfi].[PopulationServedType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_PopulationServedType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_PopulationServedType] ON [edfi].[PopulationServedType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_PostingResultType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_PostingResultType_ShortDescription] ON [edfi].[PostingResultType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_PostingResultType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_PostingResultType] ON [edfi].[PostingResultType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_PostSecondaryEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_PostSecondaryEvent] ON [edfi].[PostSecondaryEvent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_PostSecondaryEventCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_PostSecondaryEventCategoryType_ShortDescription] ON [edfi].[PostSecondaryEventCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_PostSecondaryEventCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_PostSecondaryEventCategoryType] ON [edfi].[PostSecondaryEventCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_PostSecondaryInstitutionLevelType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_PostSecondaryInstitutionLevelType_ShortDescription] ON [edfi].[PostSecondaryInstitutionLevelType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_PostSecondaryInstitutionLevelType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_PostSecondaryInstitutionLevelType] ON [edfi].[PostSecondaryInstitutionLevelType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Program]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Program] ON [edfi].[Program]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ProgramAssignmentType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ProgramAssignmentType_ShortDescription] ON [edfi].[ProgramAssignmentType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ProgramAssignmentType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ProgramAssignmentType] ON [edfi].[ProgramAssignmentType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ProgramCharacteristicType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ProgramCharacteristicType_ShortDescription] ON [edfi].[ProgramCharacteristicType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ProgramCharacteristicType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ProgramCharacteristicType] ON [edfi].[ProgramCharacteristicType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ProgramSponsorType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ProgramSponsorType_ShortDescription] ON [edfi].[ProgramSponsorType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ProgramSponsorType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ProgramSponsorType] ON [edfi].[ProgramSponsorType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ProgramType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ProgramType_ShortDescription] ON [edfi].[ProgramType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ProgramType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ProgramType] ON [edfi].[ProgramType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_PublicationStatusType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_PublicationStatusType_ShortDescription] ON [edfi].[PublicationStatusType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_PublicationStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_PublicationStatusType] ON [edfi].[PublicationStatusType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_RaceType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_RaceType_ShortDescription] ON [edfi].[RaceType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_RaceType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_RaceType] ON [edfi].[RaceType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ReasonExitedType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ReasonExitedType_ShortDescription] ON [edfi].[ReasonExitedType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ReasonExitedType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ReasonExitedType] ON [edfi].[ReasonExitedType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ReasonNotTestedType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ReasonNotTestedType_ShortDescription] ON [edfi].[ReasonNotTestedType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ReasonNotTestedType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ReasonNotTestedType] ON [edfi].[ReasonNotTestedType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_RecognitionType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_RecognitionType_ShortDescription] ON [edfi].[RecognitionType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_RecognitionType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_RecognitionType] ON [edfi].[RecognitionType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_RelationType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_RelationType_ShortDescription] ON [edfi].[RelationType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_RelationType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_RelationType] ON [edfi].[RelationType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_RepeatIdentifierType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_RepeatIdentifierType_ShortDescription] ON [edfi].[RepeatIdentifierType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_RepeatIdentifierType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_RepeatIdentifierType] ON [edfi].[RepeatIdentifierType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ReportCard]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ReportCard] ON [edfi].[ReportCard]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ReporterDescriptionType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ReporterDescriptionType_ShortDescription] ON [edfi].[ReporterDescriptionType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ReporterDescriptionType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ReporterDescriptionType] ON [edfi].[ReporterDescriptionType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ResidencyStatusType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ResidencyStatusType_ShortDescription] ON [edfi].[ResidencyStatusType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ResidencyStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ResidencyStatusType] ON [edfi].[ResidencyStatusType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ResponseIndicatorType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ResponseIndicatorType_ShortDescription] ON [edfi].[ResponseIndicatorType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ResponseIndicatorType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ResponseIndicatorType] ON [edfi].[ResponseIndicatorType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ResponsibilityType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ResponsibilityType_ShortDescription] ON [edfi].[ResponsibilityType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ResponsibilityType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ResponsibilityType] ON [edfi].[ResponsibilityType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_RestraintEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_RestraintEvent] ON [edfi].[RestraintEvent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_RestraintEventReasonType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_RestraintEventReasonType_ShortDescription] ON [edfi].[RestraintEventReasonType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_RestraintEventReasonType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_RestraintEventReasonType] ON [edfi].[RestraintEventReasonType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_ResultDatatypeType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_ResultDatatypeType_ShortDescription] ON [edfi].[ResultDatatypeType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_ResultDatatypeType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_ResultDatatypeType] ON [edfi].[ResultDatatypeType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_RetestIndicatorType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_RetestIndicatorType_ShortDescription] ON [edfi].[RetestIndicatorType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_RetestIndicatorType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_RetestIndicatorType] ON [edfi].[RetestIndicatorType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_SchoolCategoryType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SchoolCategoryType_ShortDescription] ON [edfi].[SchoolCategoryType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SchoolCategoryType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SchoolCategoryType] ON [edfi].[SchoolCategoryType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_SchoolChoiceImplementStatusType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SchoolChoiceImplementStatusType_ShortDescription] ON [edfi].[SchoolChoiceImplementStatusType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SchoolChoiceImplementStatusType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SchoolChoiceImplementStatusType] ON [edfi].[SchoolChoiceImplementStatusType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_SchoolFoodServicesEligibilityType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SchoolFoodServicesEligibilityType_ShortDescription] ON [edfi].[SchoolFoodServicesEligibilityType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SchoolFoodServicesEligibilityType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SchoolFoodServicesEligibilityType] ON [edfi].[SchoolFoodServicesEligibilityType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_SchoolType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SchoolType_ShortDescription] ON [edfi].[SchoolType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SchoolType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SchoolType] ON [edfi].[SchoolType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SchoolYearType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SchoolYearType] ON [edfi].[SchoolYearType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_SchoolYearType_CurrentSchoolYear]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_SchoolYearType_CurrentSchoolYear] ON [edfi].[SchoolYearType]
(
	[CurrentSchoolYear] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_SchoolYearType_Description]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_SchoolYearType_Description] ON [edfi].[SchoolYearType]
(
	[SchoolYearDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Section]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Section] ON [edfi].[Section]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Section_LocalCourseCode]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_Section_LocalCourseCode] ON [edfi].[Section]
(
	[LocalCourseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SectionAttendanceTakenEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SectionAttendanceTakenEvent] ON [edfi].[SectionAttendanceTakenEvent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_SectionCharacteristicType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SectionCharacteristicType_ShortDescription] ON [edfi].[SectionCharacteristicType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SectionCharacteristicType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SectionCharacteristicType] ON [edfi].[SectionCharacteristicType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_SeparationReasonType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SeparationReasonType_ShortDescription] ON [edfi].[SeparationReasonType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SeparationReasonType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SeparationReasonType] ON [edfi].[SeparationReasonType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_SeparationType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SeparationType_ShortDescription] ON [edfi].[SeparationType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SeparationType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SeparationType] ON [edfi].[SeparationType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Session]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Session] ON [edfi].[Session]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_SexType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SexType_ShortDescription] ON [edfi].[SexType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SexType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SexType] ON [edfi].[SexType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_SpecialEducationSettingType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_SpecialEducationSettingType_ShortDescription] ON [edfi].[SpecialEducationSettingType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_SpecialEducationSettingType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_SpecialEducationSettingType] ON [edfi].[SpecialEducationSettingType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Staff]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Staff] ON [edfi].[Staff]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Staff_StudentRecord]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_Staff_StudentRecord] ON [edfi].[Staff]
(
	[StaffUSI] ASC
)
INCLUDE ( 	[FirstName],
	[LastSurname]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UI_Staff_StaffUniqueId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_Staff_StaffUniqueId] ON [edfi].[Staff]
(
	[StaffUniqueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_StaffClassificationType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_StaffClassificationType_ShortDescription] ON [edfi].[StaffClassificationType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StaffClassificationType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StaffClassificationType] ON [edfi].[StaffClassificationType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StaffCohortAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StaffCohortAssociation] ON [edfi].[StaffCohortAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StaffEducationOrganizationAssignmentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StaffEducationOrganizationAssignmentAssociation] ON [edfi].[StaffEducationOrganizationAssignmentAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StaffEducationOrganizationEmploymentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StaffEducationOrganizationEmploymentAssociation] ON [edfi].[StaffEducationOrganizationEmploymentAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_StaffIdentificationSystemType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_StaffIdentificationSystemType_ShortDescription] ON [edfi].[StaffIdentificationSystemType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StaffIdentificationSystemType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StaffIdentificationSystemType] ON [edfi].[StaffIdentificationSystemType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StaffProgramAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StaffProgramAssociation] ON [edfi].[StaffProgramAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StaffSchoolAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StaffSchoolAssociation] ON [edfi].[StaffSchoolAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StaffSectionAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StaffSectionAssociation] ON [edfi].[StaffSectionAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_TeacherSectionAssociation_StudentRecord]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_TeacherSectionAssociation_StudentRecord] ON [edfi].[StaffSectionAssociation]
(
	[ClassroomIdentificationCode] ASC,
	[SchoolId] ASC,
	[TermTypeId] ASC,
	[ClassPeriodName] ASC,
	[LocalCourseCode] ASC,
	[StaffUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_StateAbbreviationType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_StateAbbreviationType_ShortDescription] ON [edfi].[StateAbbreviationType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StateAbbreviationType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StateAbbreviationType] ON [edfi].[StateAbbreviationType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StateEducationAgencyFederalFunds]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StateEducationAgencyFederalFunds] ON [edfi].[StateEducationAgencyFederalFunds]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_Student]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_Student] ON [edfi].[Student]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UI_Student_StudentUniqueId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_Student_StudentUniqueId] ON [edfi].[Student]
(
	[StudentUniqueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentAcademicRecord]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentAcademicRecord] ON [edfi].[StudentAcademicRecord]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentAssessment]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentAssessment] ON [edfi].[StudentAssessment]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_StudentAssessment_StudentRecord]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_StudentAssessment_StudentRecord] ON [edfi].[StudentAssessment]
(
	[AssessmentTitle] ASC,
	[Version] ASC,
	[AcademicSubjectDescriptorId] ASC,
	[AssessedGradeLevelDescriptorId] ASC,
	[StudentUSI] ASC,
	[AdministrationDate] ASC
)
INCLUDE ( 	[AdministrationLanguageDescriptorId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_AssessmentItem_SubjType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_AssessmentItem_SubjType] ON [edfi].[StudentAssessmentItem]
(
	[AssessmentTitle] ASC,
	[AcademicSubjectDescriptorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_StudentCharacteristicType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_StudentCharacteristicType_ShortDescription] ON [edfi].[StudentCharacteristicType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentCharacteristicType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentCharacteristicType] ON [edfi].[StudentCharacteristicType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentCohortAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentCohortAssociation] ON [edfi].[StudentCohortAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentCompetencyObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentCompetencyObjective] ON [edfi].[StudentCompetencyObjective]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentDisciplineIncidentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentDisciplineIncidentAssociation] ON [edfi].[StudentDisciplineIncidentAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentEducationOrganizationAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentEducationOrganizationAssociation] ON [edfi].[StudentEducationOrganizationAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentGradebookEntry]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentGradebookEntry] ON [edfi].[StudentGradebookEntry]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_StudentIdentificationSystemType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_StudentIdentificationSystemType_ShortDescription] ON [edfi].[StudentIdentificationSystemType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentIdentificationSystemType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentIdentificationSystemType] ON [edfi].[StudentIdentificationSystemType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentInterventionAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentInterventionAssociation] ON [edfi].[StudentInterventionAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentInterventionAttendanceEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentInterventionAttendanceEvent] ON [edfi].[StudentInterventionAttendanceEvent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_StudentInterventionAttendanceEvent_EventDate]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_StudentInterventionAttendanceEvent_EventDate] ON [edfi].[StudentInterventionAttendanceEvent]
(
	[EventDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentLearningObjective]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentLearningObjective] ON [edfi].[StudentLearningObjective]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentParentAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentParentAssociation] ON [edfi].[StudentParentAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_StudentParticipationCodeType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_StudentParticipationCodeType_ShortDescription] ON [edfi].[StudentParticipationCodeType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentParticipationCodeType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentParticipationCodeType] ON [edfi].[StudentParticipationCodeType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentProgramAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentProgramAssociation] ON [edfi].[StudentProgramAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentProgramAttendanceEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentProgramAttendanceEvent] ON [edfi].[StudentProgramAttendanceEvent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentSchoolAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentSchoolAssociation] ON [edfi].[StudentSchoolAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_StudentSchoolAssociation_ExitWithdrawDateStudentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_StudentSchoolAssociation_ExitWithdrawDateStudentUSI] ON [edfi].[StudentSchoolAssociation]
(
	[ExitWithdrawDate] ASC,
	[StudentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_StudentSchoolAssociation_StudentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_StudentSchoolAssociation_StudentUSI] ON [edfi].[StudentSchoolAssociation]
(
	[StudentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentSchoolAttendanceEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentSchoolAttendanceEvent] ON [edfi].[StudentSchoolAttendanceEvent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_StudentSchoolAttendanceEvent_EventDate]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_StudentSchoolAttendanceEvent_EventDate] ON [edfi].[StudentSchoolAttendanceEvent]
(
	[EventDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentSectionAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentSectionAssociation] ON [edfi].[StudentSectionAssociation]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_StudentSectionAssociation_BDates]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_StudentSectionAssociation_BDates] ON [edfi].[StudentSectionAssociation]
(
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_StudentSectionAssociation_EDates]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_StudentSectionAssociation_EDates] ON [edfi].[StudentSectionAssociation]
(
	[EndDate] ASC,
	[BeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_StudentSectionAttendanceEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_StudentSectionAttendanceEvent] ON [edfi].[StudentSectionAttendanceEvent]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_StudentSectionAttendanceEvent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_StudentSectionAttendanceEvent] ON [edfi].[StudentSectionAttendanceEvent]
(
	[SchoolId] ASC,
	[EventDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [IX_StudentSectionAttendanceEvent_EventDate]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_StudentSectionAttendanceEvent_EventDate] ON [edfi].[StudentSectionAttendanceEvent]
(
	[EventDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_TeachingCredentialBasisType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_TeachingCredentialBasisType_ShortDescription] ON [edfi].[TeachingCredentialBasisType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_TeachingCredentialBasisType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_TeachingCredentialBasisType] ON [edfi].[TeachingCredentialBasisType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_TeachingCredentialType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_TeachingCredentialType_ShortDescription] ON [edfi].[TeachingCredentialType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_TeachingCredentialType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_TeachingCredentialType] ON [edfi].[TeachingCredentialType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_TelephoneNumberType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_TelephoneNumberType_ShortDescription] ON [edfi].[TelephoneNumberType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_TelephoneNumberType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_TelephoneNumberType] ON [edfi].[TelephoneNumberType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_TermType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_TermType_ShortDescription] ON [edfi].[TermType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_TermType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_TermType] ON [edfi].[TermType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_TitleIPartAParticipantType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_TitleIPartAParticipantType_ShortDescription] ON [edfi].[TitleIPartAParticipantType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_TitleIPartAParticipantType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_TitleIPartAParticipantType] ON [edfi].[TitleIPartAParticipantType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_TitleIPartASchoolDesignationType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_TitleIPartASchoolDesignationType_ShortDescription] ON [edfi].[TitleIPartASchoolDesignationType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_TitleIPartASchoolDesignationType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_TitleIPartASchoolDesignationType] ON [edfi].[TitleIPartASchoolDesignationType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [AK_VisaType_ShortDescription]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [AK_VisaType_ShortDescription] ON [edfi].[VisaType]
(
	[ShortDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_VisaType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_VisaType] ON [edfi].[VisaType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
/****** Object:  Index [GUID_WeaponType]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [GUID_WeaponType] ON [edfi].[WeaponType]
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_EducationOrganizationToStaff_Assignment_StaffUniqueId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_EducationOrganizationToStaff_Assignment_StaffUniqueId] ON [auth].[EducationOrganizationToStaff_Assignment]
(
	[StaffUniqueId] ASC,
	[EducationOrganizationId] ASC,
	[StaffGuid] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_EducationOrganizationToStaff_Employment]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_EducationOrganizationToStaff_Employment] ON [auth].[EducationOrganizationToStaff_Employment]
(
	[StaffUniqueId] ASC,
	[EducationOrganizationId] ASC,
	[StaffGuid] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_LocalEducationAgency_LocalEducationAgencyId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_LocalEducationAgency_LocalEducationAgencyId] ON [auth].[LocalEducationAgency]
(
	[LocalEducationAgencyId] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_LocalEducationAgencyIdToParent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_LocalEducationAgencyIdToParent] ON [auth].[LocalEducationAgencyIdToParent]
(
	[ParentUniqueId] ASC,
	[LocalEducationAgencyId] ASC,
	[ParentGuid] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UIX_LocalEducationAgencyIdToStudent_StudentUniqueId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [UIX_LocalEducationAgencyIdToStudent_StudentUniqueId] ON [auth].[LocalEducationAgencyIdToStudent]
(
	[StudentUniqueId] ASC,
	[LocalEducationAgencyId] ASC,
	[StudentGuid] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_ParentToStudent]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_ParentToStudent] ON [auth].[ParentToStudent]
(
	[ParentUniqueId] ASC,
	[StudentUniqueId] ASC,
	[StudentGuid] ASC,
	[ParentGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_ParentUSIToStudentUSI]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_ParentUSIToStudentUSI] ON [auth].[ParentUSIToStudentUSI]
(
	[ParentUSI] ASC,
	[StudentUSI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_School_LocalEducationAgencyId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_School_LocalEducationAgencyId] ON [auth].[School]
(
	[LocalEducationAgencyId] ASC,
	[SchoolId] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [IX_School_SchoolId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_School_SchoolId] ON [auth].[School]
(
	[SchoolId] ASC,
	[LocalEducationAgencyId] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF

GO
/****** Object:  Index [UIX_SchoolIdToStudent_StudentUniqueId]    Script Date: 9/24/2015 11:35:43 AM ******/
CREATE NONCLUSTERED INDEX [UIX_SchoolIdToStudent_StudentUniqueId] ON [auth].[SchoolIdToStudent]
(
	[StudentUniqueId] ASC,
	[SchoolId] ASC,
	[StudentGuid] ASC,
	[BeginDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER TABLE [dbo].[DeleteEvent] ADD  CONSTRAINT [DeleteEvent_DF_DeletionDate]  DEFAULT (getutcdate()) FOR [DeletionDate]
GO
ALTER TABLE [EASOL].[StaffAuthentication] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [edfi].[AcademicHonorCategoryType] ADD  CONSTRAINT [AcademicHonorCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AcademicHonorCategoryType] ADD  CONSTRAINT [AcademicHonorCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AcademicHonorCategoryType] ADD  CONSTRAINT [AcademicHonorCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AcademicSubjectType] ADD  CONSTRAINT [AcademicSubjectType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AcademicSubjectType] ADD  CONSTRAINT [AcademicSubjectType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AcademicSubjectType] ADD  CONSTRAINT [AcademicSubjectType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AcademicWeek] ADD  CONSTRAINT [AcademicWeek_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AcademicWeek] ADD  CONSTRAINT [AcademicWeek_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AcademicWeek] ADD  CONSTRAINT [AcademicWeek_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AccommodationType] ADD  CONSTRAINT [AccommodationType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AccommodationType] ADD  CONSTRAINT [AccommodationType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AccommodationType] ADD  CONSTRAINT [AccommodationType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Account] ADD  CONSTRAINT [Account_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Account] ADD  CONSTRAINT [Account_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Account] ADD  CONSTRAINT [Account_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AccountabilityRating] ADD  CONSTRAINT [AccountabilityRating_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AccountabilityRating] ADD  CONSTRAINT [AccountabilityRating_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AccountabilityRating] ADD  CONSTRAINT [AccountabilityRating_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AccountCode] ADD  CONSTRAINT [AccountCode_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AchievementCategoryType] ADD  CONSTRAINT [AchievementCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AchievementCategoryType] ADD  CONSTRAINT [AchievementCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AchievementCategoryType] ADD  CONSTRAINT [AchievementCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Actual] ADD  CONSTRAINT [Actual_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Actual] ADD  CONSTRAINT [Actual_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Actual] ADD  CONSTRAINT [Actual_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AdditionalCreditType] ADD  CONSTRAINT [AdditionalCreditType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AdditionalCreditType] ADD  CONSTRAINT [AdditionalCreditType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AdditionalCreditType] ADD  CONSTRAINT [AdditionalCreditType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AddressType] ADD  CONSTRAINT [AddressType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AddressType] ADD  CONSTRAINT [AddressType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AddressType] ADD  CONSTRAINT [AddressType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AdministrationEnvironmentType] ADD  CONSTRAINT [AdministrationEnvironmentType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AdministrationEnvironmentType] ADD  CONSTRAINT [AdministrationEnvironmentType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AdministrationEnvironmentType] ADD  CONSTRAINT [AdministrationEnvironmentType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AdministrativeFundingControlType] ADD  CONSTRAINT [AdministrativeFundingControlType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AdministrativeFundingControlType] ADD  CONSTRAINT [AdministrativeFundingControlType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AdministrativeFundingControlType] ADD  CONSTRAINT [AdministrativeFundingControlType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Assessment] ADD  CONSTRAINT [Assessment_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Assessment] ADD  CONSTRAINT [Assessment_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Assessment] ADD  CONSTRAINT [Assessment_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentCategoryType] ADD  CONSTRAINT [AssessmentCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AssessmentCategoryType] ADD  CONSTRAINT [AssessmentCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AssessmentCategoryType] ADD  CONSTRAINT [AssessmentCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentContentStandard] ADD  CONSTRAINT [AssessmentContentStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentContentStandardAuthor] ADD  CONSTRAINT [AssessmentContentStandardAuthor_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentFamily] ADD  CONSTRAINT [AssessmentFamily_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AssessmentFamily] ADD  CONSTRAINT [AssessmentFamily_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AssessmentFamily] ADD  CONSTRAINT [AssessmentFamily_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentFamilyAssessmentPeriod] ADD  CONSTRAINT [AssessmentFamilyAssessmentPeriod_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandard] ADD  CONSTRAINT [AssessmentFamilyContentStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandardAuthor] ADD  CONSTRAINT [AssessmentFamilyContentStandardAuthor_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentFamilyIdentificationCode] ADD  CONSTRAINT [AssessmentFamilyIdentificationCode_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentFamilyLanguage] ADD  CONSTRAINT [AssessmentFamilyLanguage_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentIdentificationCode] ADD  CONSTRAINT [AssessmentIdentificationCode_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentIdentificationSystemType] ADD  CONSTRAINT [AssessmentIdentificationSystemType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AssessmentIdentificationSystemType] ADD  CONSTRAINT [AssessmentIdentificationSystemType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AssessmentIdentificationSystemType] ADD  CONSTRAINT [AssessmentIdentificationSystemType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentItem] ADD  CONSTRAINT [AssessmentItem_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AssessmentItem] ADD  CONSTRAINT [AssessmentItem_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AssessmentItem] ADD  CONSTRAINT [AssessmentItem_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentItemCategoryType] ADD  CONSTRAINT [AssessmentItemCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AssessmentItemCategoryType] ADD  CONSTRAINT [AssessmentItemCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AssessmentItemCategoryType] ADD  CONSTRAINT [AssessmentItemCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentItemLearningStandard] ADD  CONSTRAINT [AssessmentItemLearningStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentItemResultType] ADD  CONSTRAINT [AssessmentItemResultType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AssessmentItemResultType] ADD  CONSTRAINT [AssessmentItemResultType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AssessmentItemResultType] ADD  CONSTRAINT [AssessmentItemResultType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentLanguage] ADD  CONSTRAINT [AssessmentLanguage_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentPerformanceLevel] ADD  CONSTRAINT [AssessmentPerformanceLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentProgram] ADD  CONSTRAINT [AssessmentProgram_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentReportingMethodType] ADD  CONSTRAINT [AssessmentReportingMethodType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AssessmentReportingMethodType] ADD  CONSTRAINT [AssessmentReportingMethodType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AssessmentReportingMethodType] ADD  CONSTRAINT [AssessmentReportingMethodType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentScore] ADD  CONSTRAINT [AssessmentScore_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AssessmentSection] ADD  CONSTRAINT [AssessmentSection_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[AttendanceEventCategoryType] ADD  CONSTRAINT [AttendanceEventCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[AttendanceEventCategoryType] ADD  CONSTRAINT [AttendanceEventCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[AttendanceEventCategoryType] ADD  CONSTRAINT [AttendanceEventCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[BehaviorType] ADD  CONSTRAINT [BehaviorType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[BehaviorType] ADD  CONSTRAINT [BehaviorType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[BehaviorType] ADD  CONSTRAINT [BehaviorType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[BellSchedule] ADD  CONSTRAINT [BellSchedule_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[BellSchedule] ADD  CONSTRAINT [BellSchedule_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[BellSchedule] ADD  CONSTRAINT [BellSchedule_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[BellScheduleMeetingTime] ADD  CONSTRAINT [BellScheduleMeetingTime_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Budget] ADD  CONSTRAINT [Budget_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Budget] ADD  CONSTRAINT [Budget_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Budget] ADD  CONSTRAINT [Budget_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CalendarDate] ADD  CONSTRAINT [CalendarDate_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CalendarDate] ADD  CONSTRAINT [CalendarDate_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CalendarDate] ADD  CONSTRAINT [CalendarDate_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CalendarDateCalendarEvent] ADD  CONSTRAINT [CalendarDateCalendarEvent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CalendarEventType] ADD  CONSTRAINT [CalendarEventType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CalendarEventType] ADD  CONSTRAINT [CalendarEventType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CalendarEventType] ADD  CONSTRAINT [CalendarEventType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CareerPathwayType] ADD  CONSTRAINT [CareerPathwayType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CareerPathwayType] ADD  CONSTRAINT [CareerPathwayType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CareerPathwayType] ADD  CONSTRAINT [CareerPathwayType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CharterStatusType] ADD  CONSTRAINT [CharterStatusType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CharterStatusType] ADD  CONSTRAINT [CharterStatusType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CharterStatusType] ADD  CONSTRAINT [CharterStatusType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CitizenshipStatusType] ADD  CONSTRAINT [CitizenshipStatusType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CitizenshipStatusType] ADD  CONSTRAINT [CitizenshipStatusType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CitizenshipStatusType] ADD  CONSTRAINT [CitizenshipStatusType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ClassPeriod] ADD  CONSTRAINT [ClassPeriod_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ClassPeriod] ADD  CONSTRAINT [ClassPeriod_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ClassPeriod] ADD  CONSTRAINT [ClassPeriod_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ClassroomPositionType] ADD  CONSTRAINT [ClassroomPositionType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ClassroomPositionType] ADD  CONSTRAINT [ClassroomPositionType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ClassroomPositionType] ADD  CONSTRAINT [ClassroomPositionType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Cohort] ADD  CONSTRAINT [Cohort_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Cohort] ADD  CONSTRAINT [Cohort_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Cohort] ADD  CONSTRAINT [Cohort_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CohortProgram] ADD  CONSTRAINT [CohortProgram_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CohortScopeType] ADD  CONSTRAINT [CohortScopeType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CohortScopeType] ADD  CONSTRAINT [CohortScopeType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CohortScopeType] ADD  CONSTRAINT [CohortScopeType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CohortType] ADD  CONSTRAINT [CohortType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CohortType] ADD  CONSTRAINT [CohortType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CohortType] ADD  CONSTRAINT [CohortType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CohortYearType] ADD  CONSTRAINT [CohortYearType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CohortYearType] ADD  CONSTRAINT [CohortYearType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CohortYearType] ADD  CONSTRAINT [CohortYearType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CompetencyObjective] ADD  CONSTRAINT [CompetencyObjective_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CompetencyObjective] ADD  CONSTRAINT [CompetencyObjective_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CompetencyObjective] ADD  CONSTRAINT [CompetencyObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ContentClassType] ADD  CONSTRAINT [ContentClassType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ContentClassType] ADD  CONSTRAINT [ContentClassType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ContentClassType] ADD  CONSTRAINT [ContentClassType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ContinuationOfServicesReasonType] ADD  CONSTRAINT [ContinuationOfServicesReasonType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ContinuationOfServicesReasonType] ADD  CONSTRAINT [ContinuationOfServicesReasonType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ContinuationOfServicesReasonType] ADD  CONSTRAINT [ContinuationOfServicesReasonType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ContractedStaff] ADD  CONSTRAINT [ContractedStaff_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ContractedStaff] ADD  CONSTRAINT [ContractedStaff_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ContractedStaff] ADD  CONSTRAINT [ContractedStaff_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CostRateType] ADD  CONSTRAINT [CostRateType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CostRateType] ADD  CONSTRAINT [CostRateType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CostRateType] ADD  CONSTRAINT [CostRateType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CountryCodeType] ADD  CONSTRAINT [CountryCodeType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CountryCodeType] ADD  CONSTRAINT [CountryCodeType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CountryCodeType] ADD  CONSTRAINT [CountryCodeType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CountryType] ADD  CONSTRAINT [CountryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CountryType] ADD  CONSTRAINT [CountryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CountryType] ADD  CONSTRAINT [CountryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Course] ADD  CONSTRAINT [Course_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Course] ADD  CONSTRAINT [Course_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Course] ADD  CONSTRAINT [Course_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseAttemptResultType] ADD  CONSTRAINT [CourseAttemptResultType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CourseAttemptResultType] ADD  CONSTRAINT [CourseAttemptResultType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CourseAttemptResultType] ADD  CONSTRAINT [CourseAttemptResultType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseCodeSystemType] ADD  CONSTRAINT [CourseCodeSystemType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CourseCodeSystemType] ADD  CONSTRAINT [CourseCodeSystemType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CourseCodeSystemType] ADD  CONSTRAINT [CourseCodeSystemType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseCompetencyLevel] ADD  CONSTRAINT [CourseCompetencyLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseDefinedByType] ADD  CONSTRAINT [CourseDefinedByType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CourseDefinedByType] ADD  CONSTRAINT [CourseDefinedByType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CourseDefinedByType] ADD  CONSTRAINT [CourseDefinedByType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseGPAApplicabilityType] ADD  CONSTRAINT [CourseGPAApplicabilityType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CourseGPAApplicabilityType] ADD  CONSTRAINT [CourseGPAApplicabilityType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CourseGPAApplicabilityType] ADD  CONSTRAINT [CourseGPAApplicabilityType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseGradeLevel] ADD  CONSTRAINT [CourseGradeLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseIdentificationCode] ADD  CONSTRAINT [CourseIdentificationCode_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseLearningObjective] ADD  CONSTRAINT [CourseLearningObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseLearningStandard] ADD  CONSTRAINT [CourseLearningStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseLevelCharacteristic] ADD  CONSTRAINT [CourseLevelCharacteristic_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseLevelCharacteristicType] ADD  CONSTRAINT [CourseLevelCharacteristicType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CourseLevelCharacteristicType] ADD  CONSTRAINT [CourseLevelCharacteristicType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CourseLevelCharacteristicType] ADD  CONSTRAINT [CourseLevelCharacteristicType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseOffering] ADD  CONSTRAINT [CourseOffering_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CourseOffering] ADD  CONSTRAINT [CourseOffering_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CourseOffering] ADD  CONSTRAINT [CourseOffering_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseOfferingCurriculumUsed] ADD  CONSTRAINT [CourseOfferingCurriculumUsed_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseRepeatCodeType] ADD  CONSTRAINT [CourseRepeatCodeType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CourseRepeatCodeType] ADD  CONSTRAINT [CourseRepeatCodeType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CourseRepeatCodeType] ADD  CONSTRAINT [CourseRepeatCodeType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseTranscript] ADD  CONSTRAINT [CourseTranscript_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CourseTranscript] ADD  CONSTRAINT [CourseTranscript_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CourseTranscript] ADD  CONSTRAINT [CourseTranscript_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseTranscriptAdditionalCredit] ADD  CONSTRAINT [CourseTranscriptAdditionalCredit_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CourseTranscriptExternalCourse] ADD  CONSTRAINT [CourseTranscriptExternalCourse_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CredentialType] ADD  CONSTRAINT [CredentialType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CredentialType] ADD  CONSTRAINT [CredentialType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CredentialType] ADD  CONSTRAINT [CredentialType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CreditType] ADD  CONSTRAINT [CreditType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CreditType] ADD  CONSTRAINT [CreditType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CreditType] ADD  CONSTRAINT [CreditType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[CurriculumUsedType] ADD  CONSTRAINT [CurriculumUsedType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[CurriculumUsedType] ADD  CONSTRAINT [CurriculumUsedType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[CurriculumUsedType] ADD  CONSTRAINT [CurriculumUsedType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DeliveryMethodType] ADD  CONSTRAINT [DeliveryMethodType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DeliveryMethodType] ADD  CONSTRAINT [DeliveryMethodType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DeliveryMethodType] ADD  CONSTRAINT [DeliveryMethodType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Descriptor] ADD  CONSTRAINT [Descriptor_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Descriptor] ADD  CONSTRAINT [Descriptor_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Descriptor] ADD  CONSTRAINT [Descriptor_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DiagnosisType] ADD  CONSTRAINT [DiagnosisType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DiagnosisType] ADD  CONSTRAINT [DiagnosisType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DiagnosisType] ADD  CONSTRAINT [DiagnosisType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DiplomaLevelType] ADD  CONSTRAINT [DiplomaLevelType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DiplomaLevelType] ADD  CONSTRAINT [DiplomaLevelType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DiplomaLevelType] ADD  CONSTRAINT [DiplomaLevelType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DiplomaType] ADD  CONSTRAINT [DiplomaType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DiplomaType] ADD  CONSTRAINT [DiplomaType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DiplomaType] ADD  CONSTRAINT [DiplomaType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisabilityCategoryType] ADD  CONSTRAINT [DisabilityCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DisabilityCategoryType] ADD  CONSTRAINT [DisabilityCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DisabilityCategoryType] ADD  CONSTRAINT [DisabilityCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisabilityType] ADD  CONSTRAINT [DisabilityType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DisabilityType] ADD  CONSTRAINT [DisabilityType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DisabilityType] ADD  CONSTRAINT [DisabilityType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisciplineAction] ADD  CONSTRAINT [DisciplineAction_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DisciplineAction] ADD  CONSTRAINT [DisciplineAction_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DisciplineAction] ADD  CONSTRAINT [DisciplineAction_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisciplineActionDiscipline] ADD  CONSTRAINT [DisciplineActionDiscipline_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisciplineActionDisciplineIncident] ADD  CONSTRAINT [DisciplineActionDisciplineIncident_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisciplineActionLengthDifferenceReasonType] ADD  CONSTRAINT [DisciplineActionLengthDifferenceReasonType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DisciplineActionLengthDifferenceReasonType] ADD  CONSTRAINT [DisciplineActionLengthDifferenceReasonType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DisciplineActionLengthDifferenceReasonType] ADD  CONSTRAINT [DisciplineActionLengthDifferenceReasonType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisciplineActionStaff] ADD  CONSTRAINT [DisciplineActionStaff_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisciplineIncident] ADD  CONSTRAINT [DisciplineIncident_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DisciplineIncident] ADD  CONSTRAINT [DisciplineIncident_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DisciplineIncident] ADD  CONSTRAINT [DisciplineIncident_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisciplineIncidentBehavior] ADD  CONSTRAINT [DisciplineIncidentBehavior_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisciplineIncidentWeapon] ADD  CONSTRAINT [DisciplineIncidentWeapon_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[DisciplineType] ADD  CONSTRAINT [DisciplineType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[DisciplineType] ADD  CONSTRAINT [DisciplineType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[DisciplineType] ADD  CONSTRAINT [DisciplineType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationalEnvironmentType] ADD  CONSTRAINT [EducationalEnvironmentType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EducationalEnvironmentType] ADD  CONSTRAINT [EducationalEnvironmentType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EducationalEnvironmentType] ADD  CONSTRAINT [EducationalEnvironmentType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationContent] ADD  CONSTRAINT [EducationContent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EducationContent] ADD  CONSTRAINT [EducationContent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EducationContent] ADD  CONSTRAINT [EducationContent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationContentAppropriateGradeLevel] ADD  CONSTRAINT [EducationContentAppropriateGradeLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationContentAppropriateSex] ADD  CONSTRAINT [EducationContentAppropriateSex_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationContentAuthor] ADD  CONSTRAINT [EducationContentAuthor_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceEducationContent] ADD  CONSTRAINT [EducationContentDerivativeSourceEducationContent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceLearningResourceMetadataURI] ADD  CONSTRAINT [EducationContentDerivativeSourceLearningResourceMetadataURI_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceURI] ADD  CONSTRAINT [EducationContentDerivativeSourceURI_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationContentLanguage] ADD  CONSTRAINT [EducationContentLanguage_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganization] ADD  CONSTRAINT [EducationOrganization_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EducationOrganization] ADD  CONSTRAINT [EducationOrganization_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EducationOrganization] ADD  CONSTRAINT [EducationOrganization_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationAddress] ADD  CONSTRAINT [EducationOrganizationAddress_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationCategory] ADD  CONSTRAINT [EducationOrganizationCategory_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationCategoryType] ADD  CONSTRAINT [EducationOrganizationCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EducationOrganizationCategoryType] ADD  CONSTRAINT [EducationOrganizationCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EducationOrganizationCategoryType] ADD  CONSTRAINT [EducationOrganizationCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationIdentificationCode] ADD  CONSTRAINT [EducationOrganizationIdentificationCode_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationIdentificationSystemType] ADD  CONSTRAINT [EducationOrganizationIdentificationSystemType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EducationOrganizationIdentificationSystemType] ADD  CONSTRAINT [EducationOrganizationIdentificationSystemType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EducationOrganizationIdentificationSystemType] ADD  CONSTRAINT [EducationOrganizationIdentificationSystemType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationInstitutionTelephone] ADD  CONSTRAINT [EducationOrganizationInstitutionTelephone_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationInternationalAddress] ADD  CONSTRAINT [EducationOrganizationInternationalAddress_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationInterventionPrescriptionAssociation] ADD  CONSTRAINT [EducationOrganizationInterventionPrescriptionAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EducationOrganizationInterventionPrescriptionAssociation] ADD  CONSTRAINT [EducationOrganizationInterventionPrescriptionAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EducationOrganizationInterventionPrescriptionAssociation] ADD  CONSTRAINT [EducationOrganizationInterventionPrescriptionAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationNetworkAssociation] ADD  CONSTRAINT [EducationOrganizationNetworkAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EducationOrganizationNetworkAssociation] ADD  CONSTRAINT [EducationOrganizationNetworkAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EducationOrganizationNetworkAssociation] ADD  CONSTRAINT [EducationOrganizationNetworkAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationOrganizationPeerAssociation] ADD  CONSTRAINT [EducationOrganizationPeerAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EducationOrganizationPeerAssociation] ADD  CONSTRAINT [EducationOrganizationPeerAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EducationOrganizationPeerAssociation] ADD  CONSTRAINT [EducationOrganizationPeerAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EducationPlanType] ADD  CONSTRAINT [EducationPlanType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EducationPlanType] ADD  CONSTRAINT [EducationPlanType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EducationPlanType] ADD  CONSTRAINT [EducationPlanType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ElectronicMailType] ADD  CONSTRAINT [ElectronicMailType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ElectronicMailType] ADD  CONSTRAINT [ElectronicMailType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ElectronicMailType] ADD  CONSTRAINT [ElectronicMailType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EmploymentStatusType] ADD  CONSTRAINT [EmploymentStatusType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EmploymentStatusType] ADD  CONSTRAINT [EmploymentStatusType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EmploymentStatusType] ADD  CONSTRAINT [EmploymentStatusType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EntryGradeLevelReasonType] ADD  CONSTRAINT [EntryGradeLevelReasonType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EntryGradeLevelReasonType] ADD  CONSTRAINT [EntryGradeLevelReasonType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EntryGradeLevelReasonType] ADD  CONSTRAINT [EntryGradeLevelReasonType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EntryType] ADD  CONSTRAINT [EntryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EntryType] ADD  CONSTRAINT [EntryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EntryType] ADD  CONSTRAINT [EntryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[EventCircumstanceType] ADD  CONSTRAINT [EventCircumstanceType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[EventCircumstanceType] ADD  CONSTRAINT [EventCircumstanceType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[EventCircumstanceType] ADD  CONSTRAINT [EventCircumstanceType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ExitWithdrawType] ADD  CONSTRAINT [ExitWithdrawType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ExitWithdrawType] ADD  CONSTRAINT [ExitWithdrawType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ExitWithdrawType] ADD  CONSTRAINT [ExitWithdrawType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[FeederSchoolAssociation] ADD  CONSTRAINT [FeederSchoolAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[FeederSchoolAssociation] ADD  CONSTRAINT [FeederSchoolAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[FeederSchoolAssociation] ADD  CONSTRAINT [FeederSchoolAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Grade] ADD  CONSTRAINT [Grade_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Grade] ADD  CONSTRAINT [Grade_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Grade] ADD  CONSTRAINT [Grade_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GradebookEntry] ADD  CONSTRAINT [GradebookEntry_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[GradebookEntry] ADD  CONSTRAINT [GradebookEntry_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[GradebookEntry] ADD  CONSTRAINT [GradebookEntry_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GradebookEntryLearningObjective] ADD  CONSTRAINT [GradebookEntryLearningObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GradebookEntryLearningStandard] ADD  CONSTRAINT [GradebookEntryLearningStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GradebookEntryType] ADD  CONSTRAINT [GradebookEntryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[GradebookEntryType] ADD  CONSTRAINT [GradebookEntryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[GradebookEntryType] ADD  CONSTRAINT [GradebookEntryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GradeLevelType] ADD  CONSTRAINT [GradeLevelType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[GradeLevelType] ADD  CONSTRAINT [GradeLevelType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[GradeLevelType] ADD  CONSTRAINT [GradeLevelType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GradeType] ADD  CONSTRAINT [GradeType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[GradeType] ADD  CONSTRAINT [GradeType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[GradeType] ADD  CONSTRAINT [GradeType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GradingPeriod] ADD  CONSTRAINT [GradingPeriod_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[GradingPeriod] ADD  CONSTRAINT [GradingPeriod_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[GradingPeriod] ADD  CONSTRAINT [GradingPeriod_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GradingPeriodType] ADD  CONSTRAINT [GradingPeriodType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[GradingPeriodType] ADD  CONSTRAINT [GradingPeriodType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[GradingPeriodType] ADD  CONSTRAINT [GradingPeriodType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GraduationPlan] ADD  CONSTRAINT [GraduationPlan_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[GraduationPlan] ADD  CONSTRAINT [GraduationPlan_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[GraduationPlan] ADD  CONSTRAINT [GraduationPlan_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourse] ADD  CONSTRAINT [GraduationPlanCreditsByCourse_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourseCourse] ADD  CONSTRAINT [GraduationPlanCreditsByCourseCourse_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsBySubject] ADD  CONSTRAINT [GraduationPlanCreditsBySubject_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GraduationPlanType] ADD  CONSTRAINT [GraduationPlanType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[GraduationPlanType] ADD  CONSTRAINT [GraduationPlanType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[GraduationPlanType] ADD  CONSTRAINT [GraduationPlanType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[GunFreeSchoolsActReportingStatusType] ADD  CONSTRAINT [GunFreeSchoolsActReportingStatusType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[GunFreeSchoolsActReportingStatusType] ADD  CONSTRAINT [GunFreeSchoolsActReportingStatusType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[GunFreeSchoolsActReportingStatusType] ADD  CONSTRAINT [GunFreeSchoolsActReportingStatusType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[IdentificationDocumentUseType] ADD  CONSTRAINT [IdentificationDocumentUseType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[IdentificationDocumentUseType] ADD  CONSTRAINT [IdentificationDocumentUseType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[IdentificationDocumentUseType] ADD  CONSTRAINT [IdentificationDocumentUseType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[IncidentLocationType] ADD  CONSTRAINT [IncidentLocationType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[IncidentLocationType] ADD  CONSTRAINT [IncidentLocationType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[IncidentLocationType] ADD  CONSTRAINT [IncidentLocationType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InstitutionTelephoneNumberType] ADD  CONSTRAINT [InstitutionTelephoneNumberType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[InstitutionTelephoneNumberType] ADD  CONSTRAINT [InstitutionTelephoneNumberType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[InstitutionTelephoneNumberType] ADD  CONSTRAINT [InstitutionTelephoneNumberType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[IntegratedTechnologyStatusType] ADD  CONSTRAINT [IntegratedTechnologyStatusType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[IntegratedTechnologyStatusType] ADD  CONSTRAINT [IntegratedTechnologyStatusType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[IntegratedTechnologyStatusType] ADD  CONSTRAINT [IntegratedTechnologyStatusType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InteractivityStyleType] ADD  CONSTRAINT [InteractivityStyleType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[InteractivityStyleType] ADD  CONSTRAINT [InteractivityStyleType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[InteractivityStyleType] ADD  CONSTRAINT [InteractivityStyleType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InternetAccessType] ADD  CONSTRAINT [InternetAccessType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[InternetAccessType] ADD  CONSTRAINT [InternetAccessType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[InternetAccessType] ADD  CONSTRAINT [InternetAccessType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Intervention] ADD  CONSTRAINT [Intervention_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Intervention] ADD  CONSTRAINT [Intervention_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Intervention] ADD  CONSTRAINT [Intervention_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionAppropriateGradeLevel] ADD  CONSTRAINT [InterventionAppropriateGradeLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionAppropriateSex] ADD  CONSTRAINT [InterventionAppropriateSex_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionClassType] ADD  CONSTRAINT [InterventionClassType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[InterventionClassType] ADD  CONSTRAINT [InterventionClassType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[InterventionClassType] ADD  CONSTRAINT [InterventionClassType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionDiagnosis] ADD  CONSTRAINT [InterventionDiagnosis_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionEducationContent] ADD  CONSTRAINT [InterventionEducationContent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionEffectivenessRatingType] ADD  CONSTRAINT [InterventionEffectivenessRatingType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[InterventionEffectivenessRatingType] ADD  CONSTRAINT [InterventionEffectivenessRatingType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[InterventionEffectivenessRatingType] ADD  CONSTRAINT [InterventionEffectivenessRatingType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionInterventionPrescription] ADD  CONSTRAINT [InterventionInterventionPrescription_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionLearningResourceMetadataURI] ADD  CONSTRAINT [InterventionLearningResourceMetadataURI_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionMeetingTime] ADD  CONSTRAINT [InterventionMeetingTime_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionPopulationServed] ADD  CONSTRAINT [InterventionPopulationServed_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionPrescription] ADD  CONSTRAINT [InterventionPrescription_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[InterventionPrescription] ADD  CONSTRAINT [InterventionPrescription_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[InterventionPrescription] ADD  CONSTRAINT [InterventionPrescription_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateGradeLevel] ADD  CONSTRAINT [InterventionPrescriptionAppropriateGradeLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateSex] ADD  CONSTRAINT [InterventionPrescriptionAppropriateSex_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionPrescriptionDiagnosis] ADD  CONSTRAINT [InterventionPrescriptionDiagnosis_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionPrescriptionEducationContent] ADD  CONSTRAINT [InterventionPrescriptionEducationContent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionPrescriptionLearningResourceMetadataURI] ADD  CONSTRAINT [InterventionPrescriptionLearningResourceMetadataURI_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionPrescriptionPopulationServed] ADD  CONSTRAINT [InterventionPrescriptionPopulationServed_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionPrescriptionURI] ADD  CONSTRAINT [InterventionPrescriptionURI_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStaff] ADD  CONSTRAINT [InterventionStaff_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStudy] ADD  CONSTRAINT [InterventionStudy_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[InterventionStudy] ADD  CONSTRAINT [InterventionStudy_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[InterventionStudy] ADD  CONSTRAINT [InterventionStudy_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateGradeLevel] ADD  CONSTRAINT [InterventionStudyAppropriateGradeLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateSex] ADD  CONSTRAINT [InterventionStudyAppropriateSex_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStudyEducationContent] ADD  CONSTRAINT [InterventionStudyEducationContent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness] ADD  CONSTRAINT [InterventionStudyInterventionEffectiveness_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStudyLearningResourceMetadataURI] ADD  CONSTRAINT [InterventionStudyLearningResourceMetadataURI_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStudyPopulationServed] ADD  CONSTRAINT [InterventionStudyPopulationServed_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStudyStateAbbreviation] ADD  CONSTRAINT [InterventionStudyStateAbbreviation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionStudyURI] ADD  CONSTRAINT [InterventionStudyURI_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[InterventionURI] ADD  CONSTRAINT [InterventionURI_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LanguageType] ADD  CONSTRAINT [LanguageType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LanguageType] ADD  CONSTRAINT [LanguageType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LanguageType] ADD  CONSTRAINT [LanguageType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LanguageUseType] ADD  CONSTRAINT [LanguageUseType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LanguageUseType] ADD  CONSTRAINT [LanguageUseType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LanguageUseType] ADD  CONSTRAINT [LanguageUseType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LearningObjective] ADD  CONSTRAINT [LearningObjective_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LearningObjective] ADD  CONSTRAINT [LearningObjective_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LearningObjective] ADD  CONSTRAINT [LearningObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandard] ADD  CONSTRAINT [LearningObjectiveContentStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandardAuthor] ADD  CONSTRAINT [LearningObjectiveContentStandardAuthor_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LearningObjectiveLearningStandard] ADD  CONSTRAINT [LearningObjectiveLearningStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LearningStandard] ADD  CONSTRAINT [LearningStandard_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LearningStandard] ADD  CONSTRAINT [LearningStandard_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LearningStandard] ADD  CONSTRAINT [LearningStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LearningStandardContentStandard] ADD  CONSTRAINT [LearningStandardContentStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LearningStandardContentStandardAuthor] ADD  CONSTRAINT [LearningStandardContentStandardAuthor_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LearningStandardIdentificationCode] ADD  CONSTRAINT [LearningStandardIdentificationCode_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LearningStandardPrerequisiteLearningStandard] ADD  CONSTRAINT [LearningStandardPrerequisiteLearningStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LeaveEvent] ADD  CONSTRAINT [LeaveEvent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LeaveEvent] ADD  CONSTRAINT [LeaveEvent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LeaveEvent] ADD  CONSTRAINT [LeaveEvent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LeaveEventCategoryType] ADD  CONSTRAINT [LeaveEventCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LeaveEventCategoryType] ADD  CONSTRAINT [LeaveEventCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LeaveEventCategoryType] ADD  CONSTRAINT [LeaveEventCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LevelDescriptorGradeLevel] ADD  CONSTRAINT [LevelDescriptorGradeLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LevelOfEducationType] ADD  CONSTRAINT [LevelOfEducationType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LevelOfEducationType] ADD  CONSTRAINT [LevelOfEducationType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LevelOfEducationType] ADD  CONSTRAINT [LevelOfEducationType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LimitedEnglishProficiencyType] ADD  CONSTRAINT [LimitedEnglishProficiencyType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LimitedEnglishProficiencyType] ADD  CONSTRAINT [LimitedEnglishProficiencyType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LimitedEnglishProficiencyType] ADD  CONSTRAINT [LimitedEnglishProficiencyType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LocalEducationAgencyAccountability] ADD  CONSTRAINT [LocalEducationAgencyAccountability_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LocalEducationAgencyCategoryType] ADD  CONSTRAINT [LocalEducationAgencyCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LocalEducationAgencyCategoryType] ADD  CONSTRAINT [LocalEducationAgencyCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LocalEducationAgencyCategoryType] ADD  CONSTRAINT [LocalEducationAgencyCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[LocalEducationAgencyFederalFunds] ADD  CONSTRAINT [LocalEducationAgencyFederalFunds_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[LocalEducationAgencyFederalFunds] ADD  CONSTRAINT [LocalEducationAgencyFederalFunds_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[LocalEducationAgencyFederalFunds] ADD  CONSTRAINT [LocalEducationAgencyFederalFunds_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Location] ADD  CONSTRAINT [Location_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Location] ADD  CONSTRAINT [Location_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Location] ADD  CONSTRAINT [Location_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[MagnetSpecialProgramEmphasisSchoolType] ADD  CONSTRAINT [MagnetSpecialProgramEmphasisSchoolType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[MagnetSpecialProgramEmphasisSchoolType] ADD  CONSTRAINT [MagnetSpecialProgramEmphasisSchoolType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[MagnetSpecialProgramEmphasisSchoolType] ADD  CONSTRAINT [MagnetSpecialProgramEmphasisSchoolType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[MediumOfInstructionType] ADD  CONSTRAINT [MediumOfInstructionType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[MediumOfInstructionType] ADD  CONSTRAINT [MediumOfInstructionType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[MediumOfInstructionType] ADD  CONSTRAINT [MediumOfInstructionType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[MeetingDayType] ADD  CONSTRAINT [MeetingDayType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[MeetingDayType] ADD  CONSTRAINT [MeetingDayType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[MeetingDayType] ADD  CONSTRAINT [MeetingDayType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[MethodCreditEarnedType] ADD  CONSTRAINT [MethodCreditEarnedType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[MethodCreditEarnedType] ADD  CONSTRAINT [MethodCreditEarnedType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[MethodCreditEarnedType] ADD  CONSTRAINT [MethodCreditEarnedType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[NetworkPurposeType] ADD  CONSTRAINT [NetworkPurposeType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[NetworkPurposeType] ADD  CONSTRAINT [NetworkPurposeType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[NetworkPurposeType] ADD  CONSTRAINT [NetworkPurposeType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ObjectiveAssessment] ADD  CONSTRAINT [ObjectiveAssessment_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ObjectiveAssessment] ADD  CONSTRAINT [ObjectiveAssessment_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ObjectiveAssessment] ADD  CONSTRAINT [ObjectiveAssessment_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentAssessmentItem] ADD  CONSTRAINT [ObjectiveAssessmentAssessmentItem_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningObjective] ADD  CONSTRAINT [ObjectiveAssessmentLearningObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningStandard] ADD  CONSTRAINT [ObjectiveAssessmentLearningStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentPerformanceLevel] ADD  CONSTRAINT [ObjectiveAssessmentPerformanceLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[OldEthnicityType] ADD  CONSTRAINT [OldEthnicityType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[OldEthnicityType] ADD  CONSTRAINT [OldEthnicityType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[OldEthnicityType] ADD  CONSTRAINT [OldEthnicityType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[OpenStaffPosition] ADD  CONSTRAINT [OpenStaffPosition_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[OpenStaffPosition] ADD  CONSTRAINT [OpenStaffPosition_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[OpenStaffPosition] ADD  CONSTRAINT [OpenStaffPosition_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[OpenStaffPositionAcademicSubject] ADD  CONSTRAINT [OpenStaffPositionAcademicSubject_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[OpenStaffPositionInstructionalGradeLevel] ADD  CONSTRAINT [OpenStaffPositionInstructionalGradeLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[OperationalStatusType] ADD  CONSTRAINT [OperationalStatusType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[OperationalStatusType] ADD  CONSTRAINT [OperationalStatusType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[OperationalStatusType] ADD  CONSTRAINT [OperationalStatusType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[OtherNameType] ADD  CONSTRAINT [OtherNameType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[OtherNameType] ADD  CONSTRAINT [OtherNameType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[OtherNameType] ADD  CONSTRAINT [OtherNameType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Parent] ADD  CONSTRAINT [Parent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Parent] ADD  CONSTRAINT [Parent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Parent] ADD  CONSTRAINT [Parent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ParentAddress] ADD  CONSTRAINT [ParentAddress_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ParentElectronicMail] ADD  CONSTRAINT [ParentElectronicMail_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ParentIdentificationDocument] ADD  CONSTRAINT [ParentIdentificationDocument_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ParentInternationalAddress] ADD  CONSTRAINT [ParentInternationalAddress_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ParentOtherName] ADD  CONSTRAINT [ParentOtherName_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ParentTelephone] ADD  CONSTRAINT [ParentTelephone_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Payroll] ADD  CONSTRAINT [Payroll_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Payroll] ADD  CONSTRAINT [Payroll_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Payroll] ADD  CONSTRAINT [Payroll_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PerformanceBaseConversionType] ADD  CONSTRAINT [PerformanceBaseConversionType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[PerformanceBaseConversionType] ADD  CONSTRAINT [PerformanceBaseConversionType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[PerformanceBaseConversionType] ADD  CONSTRAINT [PerformanceBaseConversionType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PersonalInformationVerificationType] ADD  CONSTRAINT [PersonalInformationVerificationType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[PersonalInformationVerificationType] ADD  CONSTRAINT [PersonalInformationVerificationType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[PersonalInformationVerificationType] ADD  CONSTRAINT [PersonalInformationVerificationType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PopulationServedType] ADD  CONSTRAINT [PopulationServedType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[PopulationServedType] ADD  CONSTRAINT [PopulationServedType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[PopulationServedType] ADD  CONSTRAINT [PopulationServedType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PostingResultType] ADD  CONSTRAINT [PostingResultType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[PostingResultType] ADD  CONSTRAINT [PostingResultType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[PostingResultType] ADD  CONSTRAINT [PostingResultType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PostSecondaryEvent] ADD  CONSTRAINT [PostSecondaryEvent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[PostSecondaryEvent] ADD  CONSTRAINT [PostSecondaryEvent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[PostSecondaryEvent] ADD  CONSTRAINT [PostSecondaryEvent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PostSecondaryEventCategoryType] ADD  CONSTRAINT [PostSecondaryEventCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[PostSecondaryEventCategoryType] ADD  CONSTRAINT [PostSecondaryEventCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[PostSecondaryEventCategoryType] ADD  CONSTRAINT [PostSecondaryEventCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitution] ADD  CONSTRAINT [PostSecondaryEventPostSecondaryInstitution_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionIdentificationCode] ADD  CONSTRAINT [PostSecondaryEventPostSecondaryInstitutionIdentificationCode_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction] ADD  CONSTRAINT [PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PostSecondaryInstitutionLevelType] ADD  CONSTRAINT [PostSecondaryInstitutionLevelType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[PostSecondaryInstitutionLevelType] ADD  CONSTRAINT [PostSecondaryInstitutionLevelType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[PostSecondaryInstitutionLevelType] ADD  CONSTRAINT [PostSecondaryInstitutionLevelType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Program] ADD  CONSTRAINT [Program_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Program] ADD  CONSTRAINT [Program_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Program] ADD  CONSTRAINT [Program_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ProgramAssignmentType] ADD  CONSTRAINT [ProgramAssignmentType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ProgramAssignmentType] ADD  CONSTRAINT [ProgramAssignmentType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ProgramAssignmentType] ADD  CONSTRAINT [ProgramAssignmentType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ProgramCharacteristic] ADD  CONSTRAINT [ProgramCharacteristic_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ProgramCharacteristicType] ADD  CONSTRAINT [ProgramCharacteristicType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ProgramCharacteristicType] ADD  CONSTRAINT [ProgramCharacteristicType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ProgramCharacteristicType] ADD  CONSTRAINT [ProgramCharacteristicType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ProgramLearningObjective] ADD  CONSTRAINT [ProgramLearningObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ProgramLearningStandard] ADD  CONSTRAINT [ProgramLearningStandard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ProgramService] ADD  CONSTRAINT [ProgramService_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ProgramSponsorType] ADD  CONSTRAINT [ProgramSponsorType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ProgramSponsorType] ADD  CONSTRAINT [ProgramSponsorType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ProgramSponsorType] ADD  CONSTRAINT [ProgramSponsorType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ProgramType] ADD  CONSTRAINT [ProgramType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ProgramType] ADD  CONSTRAINT [ProgramType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ProgramType] ADD  CONSTRAINT [ProgramType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[PublicationStatusType] ADD  CONSTRAINT [PublicationStatusType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[PublicationStatusType] ADD  CONSTRAINT [PublicationStatusType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[PublicationStatusType] ADD  CONSTRAINT [PublicationStatusType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[RaceType] ADD  CONSTRAINT [RaceType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[RaceType] ADD  CONSTRAINT [RaceType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[RaceType] ADD  CONSTRAINT [RaceType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ReasonExitedType] ADD  CONSTRAINT [ReasonExitedType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ReasonExitedType] ADD  CONSTRAINT [ReasonExitedType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ReasonExitedType] ADD  CONSTRAINT [ReasonExitedType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ReasonNotTestedType] ADD  CONSTRAINT [ReasonNotTestedType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ReasonNotTestedType] ADD  CONSTRAINT [ReasonNotTestedType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ReasonNotTestedType] ADD  CONSTRAINT [ReasonNotTestedType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[RecognitionType] ADD  CONSTRAINT [RecognitionType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[RecognitionType] ADD  CONSTRAINT [RecognitionType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[RecognitionType] ADD  CONSTRAINT [RecognitionType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[RelationType] ADD  CONSTRAINT [RelationType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[RelationType] ADD  CONSTRAINT [RelationType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[RelationType] ADD  CONSTRAINT [RelationType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[RepeatIdentifierType] ADD  CONSTRAINT [RepeatIdentifierType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[RepeatIdentifierType] ADD  CONSTRAINT [RepeatIdentifierType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[RepeatIdentifierType] ADD  CONSTRAINT [RepeatIdentifierType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ReportCard] ADD  CONSTRAINT [ReportCard_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ReportCard] ADD  CONSTRAINT [ReportCard_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ReportCard] ADD  CONSTRAINT [ReportCard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ReportCardGrade] ADD  CONSTRAINT [ReportCardGrade_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ReportCardStudentCompetencyObjective] ADD  CONSTRAINT [ReportCardStudentCompetencyObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ReportCardStudentLearningObjective] ADD  CONSTRAINT [ReportCardStudentLearningObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ReporterDescriptionType] ADD  CONSTRAINT [ReporterDescriptionType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ReporterDescriptionType] ADD  CONSTRAINT [ReporterDescriptionType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ReporterDescriptionType] ADD  CONSTRAINT [ReporterDescriptionType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ResidencyStatusType] ADD  CONSTRAINT [ResidencyStatusType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ResidencyStatusType] ADD  CONSTRAINT [ResidencyStatusType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ResidencyStatusType] ADD  CONSTRAINT [ResidencyStatusType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ResponseIndicatorType] ADD  CONSTRAINT [ResponseIndicatorType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ResponseIndicatorType] ADD  CONSTRAINT [ResponseIndicatorType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ResponseIndicatorType] ADD  CONSTRAINT [ResponseIndicatorType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ResponsibilityType] ADD  CONSTRAINT [ResponsibilityType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ResponsibilityType] ADD  CONSTRAINT [ResponsibilityType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ResponsibilityType] ADD  CONSTRAINT [ResponsibilityType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[RestraintEvent] ADD  CONSTRAINT [RestraintEvent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[RestraintEvent] ADD  CONSTRAINT [RestraintEvent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[RestraintEvent] ADD  CONSTRAINT [RestraintEvent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[RestraintEventProgram] ADD  CONSTRAINT [RestraintEventProgram_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[RestraintEventReason] ADD  CONSTRAINT [RestraintEventReason_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[RestraintEventReasonType] ADD  CONSTRAINT [RestraintEventReasonType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[RestraintEventReasonType] ADD  CONSTRAINT [RestraintEventReasonType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[RestraintEventReasonType] ADD  CONSTRAINT [RestraintEventReasonType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[ResultDatatypeType] ADD  CONSTRAINT [ResultDatatypeType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[ResultDatatypeType] ADD  CONSTRAINT [ResultDatatypeType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[ResultDatatypeType] ADD  CONSTRAINT [ResultDatatypeType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[RetestIndicatorType] ADD  CONSTRAINT [RetestIndicatorType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[RetestIndicatorType] ADD  CONSTRAINT [RetestIndicatorType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[RetestIndicatorType] ADD  CONSTRAINT [RetestIndicatorType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SchoolCategory] ADD  CONSTRAINT [SchoolCategory_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SchoolCategoryType] ADD  CONSTRAINT [SchoolCategoryType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SchoolCategoryType] ADD  CONSTRAINT [SchoolCategoryType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SchoolCategoryType] ADD  CONSTRAINT [SchoolCategoryType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SchoolChoiceImplementStatusType] ADD  CONSTRAINT [SchoolChoiceImplementStatusType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SchoolChoiceImplementStatusType] ADD  CONSTRAINT [SchoolChoiceImplementStatusType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SchoolChoiceImplementStatusType] ADD  CONSTRAINT [SchoolChoiceImplementStatusType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SchoolFoodServicesEligibilityType] ADD  CONSTRAINT [SchoolFoodServicesEligibilityType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SchoolFoodServicesEligibilityType] ADD  CONSTRAINT [SchoolFoodServicesEligibilityType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SchoolFoodServicesEligibilityType] ADD  CONSTRAINT [SchoolFoodServicesEligibilityType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SchoolGradeLevel] ADD  CONSTRAINT [SchoolGradeLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SchoolType] ADD  CONSTRAINT [SchoolType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SchoolType] ADD  CONSTRAINT [SchoolType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SchoolType] ADD  CONSTRAINT [SchoolType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SchoolYearType] ADD  CONSTRAINT [SchoolYearType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SchoolYearType] ADD  CONSTRAINT [SchoolYearType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SchoolYearType] ADD  CONSTRAINT [SchoolYearType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Section] ADD  CONSTRAINT [Section_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Section] ADD  CONSTRAINT [Section_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Section] ADD  CONSTRAINT [Section_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SectionAttendanceTakenEvent] ADD  CONSTRAINT [SectionAttendanceTakenEvent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SectionAttendanceTakenEvent] ADD  CONSTRAINT [SectionAttendanceTakenEvent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SectionAttendanceTakenEvent] ADD  CONSTRAINT [SectionAttendanceTakenEvent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SectionCharacteristic] ADD  CONSTRAINT [SectionCharacteristic_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SectionCharacteristicType] ADD  CONSTRAINT [SectionCharacteristicType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SectionCharacteristicType] ADD  CONSTRAINT [SectionCharacteristicType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SectionCharacteristicType] ADD  CONSTRAINT [SectionCharacteristicType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SectionProgram] ADD  CONSTRAINT [SectionProgram_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SeparationReasonType] ADD  CONSTRAINT [SeparationReasonType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SeparationReasonType] ADD  CONSTRAINT [SeparationReasonType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SeparationReasonType] ADD  CONSTRAINT [SeparationReasonType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SeparationType] ADD  CONSTRAINT [SeparationType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SeparationType] ADD  CONSTRAINT [SeparationType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SeparationType] ADD  CONSTRAINT [SeparationType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Session] ADD  CONSTRAINT [Session_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Session] ADD  CONSTRAINT [Session_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Session] ADD  CONSTRAINT [Session_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SessionAcademicWeek] ADD  CONSTRAINT [SessionAcademicWeek_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SessionGradingPeriod] ADD  CONSTRAINT [SessionGradingPeriod_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SexType] ADD  CONSTRAINT [SexType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SexType] ADD  CONSTRAINT [SexType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SexType] ADD  CONSTRAINT [SexType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[SpecialEducationSettingType] ADD  CONSTRAINT [SpecialEducationSettingType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[SpecialEducationSettingType] ADD  CONSTRAINT [SpecialEducationSettingType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[SpecialEducationSettingType] ADD  CONSTRAINT [SpecialEducationSettingType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Staff] ADD  CONSTRAINT [Staff_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Staff] ADD  CONSTRAINT [Staff_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Staff] ADD  CONSTRAINT [Staff_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffAddress] ADD  CONSTRAINT [StaffAddress_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffClassificationType] ADD  CONSTRAINT [StaffClassificationType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StaffClassificationType] ADD  CONSTRAINT [StaffClassificationType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StaffClassificationType] ADD  CONSTRAINT [StaffClassificationType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffCohortAssociation] ADD  CONSTRAINT [StaffCohortAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StaffCohortAssociation] ADD  CONSTRAINT [StaffCohortAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StaffCohortAssociation] ADD  CONSTRAINT [StaffCohortAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffCredential] ADD  CONSTRAINT [StaffCredential_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation] ADD  CONSTRAINT [StaffEducationOrganizationAssignmentAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation] ADD  CONSTRAINT [StaffEducationOrganizationAssignmentAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation] ADD  CONSTRAINT [StaffEducationOrganizationAssignmentAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation] ADD  CONSTRAINT [StaffEducationOrganizationEmploymentAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation] ADD  CONSTRAINT [StaffEducationOrganizationEmploymentAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation] ADD  CONSTRAINT [StaffEducationOrganizationEmploymentAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffElectronicMail] ADD  CONSTRAINT [StaffElectronicMail_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffIdentificationCode] ADD  CONSTRAINT [StaffIdentificationCode_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffIdentificationDocument] ADD  CONSTRAINT [StaffIdentificationDocument_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffIdentificationSystemType] ADD  CONSTRAINT [StaffIdentificationSystemType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StaffIdentificationSystemType] ADD  CONSTRAINT [StaffIdentificationSystemType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StaffIdentificationSystemType] ADD  CONSTRAINT [StaffIdentificationSystemType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffInternationalAddress] ADD  CONSTRAINT [StaffInternationalAddress_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffLanguage] ADD  CONSTRAINT [StaffLanguage_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffLanguageUse] ADD  CONSTRAINT [StaffLanguageUse_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffOtherName] ADD  CONSTRAINT [StaffOtherName_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffProgramAssociation] ADD  CONSTRAINT [StaffProgramAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StaffProgramAssociation] ADD  CONSTRAINT [StaffProgramAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StaffProgramAssociation] ADD  CONSTRAINT [StaffProgramAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffRace] ADD  CONSTRAINT [StaffRace_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffSchoolAssociation] ADD  CONSTRAINT [StaffSchoolAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StaffSchoolAssociation] ADD  CONSTRAINT [StaffSchoolAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StaffSchoolAssociation] ADD  CONSTRAINT [StaffSchoolAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffSchoolAssociationAcademicSubject] ADD  CONSTRAINT [StaffSchoolAssociationAcademicSubject_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffSchoolAssociationGradeLevel] ADD  CONSTRAINT [StaffSchoolAssociationGradeLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffSectionAssociation] ADD  CONSTRAINT [StaffSectionAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StaffSectionAssociation] ADD  CONSTRAINT [StaffSectionAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StaffSectionAssociation] ADD  CONSTRAINT [StaffSectionAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffTelephone] ADD  CONSTRAINT [StaffTelephone_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StaffVisa] ADD  CONSTRAINT [StaffVisa_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StateAbbreviationType] ADD  CONSTRAINT [StateAbbreviationType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StateAbbreviationType] ADD  CONSTRAINT [StateAbbreviationType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StateAbbreviationType] ADD  CONSTRAINT [StateAbbreviationType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StateEducationAgencyAccountability] ADD  CONSTRAINT [StateEducationAgencyAccountability_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StateEducationAgencyFederalFunds] ADD  CONSTRAINT [StateEducationAgencyFederalFunds_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StateEducationAgencyFederalFunds] ADD  CONSTRAINT [StateEducationAgencyFederalFunds_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StateEducationAgencyFederalFunds] ADD  CONSTRAINT [StateEducationAgencyFederalFunds_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[Student] ADD  CONSTRAINT [Student_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[Student] ADD  CONSTRAINT [Student_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[Student] ADD  CONSTRAINT [Student_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAcademicRecord] ADD  CONSTRAINT [StudentAcademicRecord_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentAcademicRecord] ADD  CONSTRAINT [StudentAcademicRecord_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentAcademicRecord] ADD  CONSTRAINT [StudentAcademicRecord_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAcademicRecordAcademicHonor] ADD  CONSTRAINT [StudentAcademicRecordAcademicHonor_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAcademicRecordClassRanking] ADD  CONSTRAINT [StudentAcademicRecordClassRanking_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAcademicRecordDiploma] ADD  CONSTRAINT [StudentAcademicRecordDiploma_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAcademicRecordRecognition] ADD  CONSTRAINT [StudentAcademicRecordRecognition_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAcademicRecordReportCard] ADD  CONSTRAINT [StudentAcademicRecordReportCard_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAddress] ADD  CONSTRAINT [StudentAddress_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAssessment] ADD  CONSTRAINT [StudentAssessment_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentAssessment] ADD  CONSTRAINT [StudentAssessment_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentAssessment] ADD  CONSTRAINT [StudentAssessment_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAssessmentAccommodation] ADD  CONSTRAINT [StudentAssessmentAccommodation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAssessmentItem] ADD  CONSTRAINT [StudentAssessmentItem_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAssessmentPerformanceLevel] ADD  CONSTRAINT [StudentAssessmentPerformanceLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAssessmentScoreResult] ADD  CONSTRAINT [StudentAssessmentScoreResult_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessment] ADD  CONSTRAINT [StudentAssessmentStudentObjectiveAssessment_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentPerformanceLevel] ADD  CONSTRAINT [StudentAssessmentStudentObjectiveAssessmentPerformanceLevel_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult] ADD  CONSTRAINT [StudentAssessmentStudentObjectiveAssessmentScoreResult_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentCharacteristic] ADD  CONSTRAINT [StudentCharacteristic_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentCharacteristicType] ADD  CONSTRAINT [StudentCharacteristicType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentCharacteristicType] ADD  CONSTRAINT [StudentCharacteristicType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentCharacteristicType] ADD  CONSTRAINT [StudentCharacteristicType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentCohortAssociation] ADD  CONSTRAINT [StudentCohortAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentCohortAssociation] ADD  CONSTRAINT [StudentCohortAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentCohortAssociation] ADD  CONSTRAINT [StudentCohortAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentCohortAssociationSection] ADD  CONSTRAINT [StudentCohortAssociationSection_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentCohortYear] ADD  CONSTRAINT [StudentCohortYear_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentCompetencyObjective] ADD  CONSTRAINT [StudentCompetencyObjective_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentCompetencyObjective] ADD  CONSTRAINT [StudentCompetencyObjective_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentCompetencyObjective] ADD  CONSTRAINT [StudentCompetencyObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentCTEProgramAssociationCTEProgram] ADD  CONSTRAINT [StudentCTEProgramAssociationCTEProgram_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentDisability] ADD  CONSTRAINT [StudentDisability_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociation] ADD  CONSTRAINT [StudentDisciplineIncidentAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociation] ADD  CONSTRAINT [StudentDisciplineIncidentAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociation] ADD  CONSTRAINT [StudentDisciplineIncidentAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociationBehavior] ADD  CONSTRAINT [StudentDisciplineIncidentAssociationBehavior_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentEducationOrganizationAssociation] ADD  CONSTRAINT [StudentEducationOrganizationAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentEducationOrganizationAssociation] ADD  CONSTRAINT [StudentEducationOrganizationAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentEducationOrganizationAssociation] ADD  CONSTRAINT [StudentEducationOrganizationAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentElectronicMail] ADD  CONSTRAINT [StudentElectronicMail_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentGradebookEntry] ADD  CONSTRAINT [StudentGradebookEntry_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentGradebookEntry] ADD  CONSTRAINT [StudentGradebookEntry_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentGradebookEntry] ADD  CONSTRAINT [StudentGradebookEntry_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentIdentificationCode] ADD  CONSTRAINT [StudentIdentificationCode_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentIdentificationDocument] ADD  CONSTRAINT [StudentIdentificationDocument_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentIdentificationSystemType] ADD  CONSTRAINT [StudentIdentificationSystemType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentIdentificationSystemType] ADD  CONSTRAINT [StudentIdentificationSystemType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentIdentificationSystemType] ADD  CONSTRAINT [StudentIdentificationSystemType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentIndicator] ADD  CONSTRAINT [StudentIndicator_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentInternationalAddress] ADD  CONSTRAINT [StudentInternationalAddress_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentInterventionAssociation] ADD  CONSTRAINT [StudentInterventionAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentInterventionAssociation] ADD  CONSTRAINT [StudentInterventionAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentInterventionAssociation] ADD  CONSTRAINT [StudentInterventionAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness] ADD  CONSTRAINT [StudentInterventionAssociationInterventionEffectiveness_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent] ADD  CONSTRAINT [StudentInterventionAttendanceEvent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent] ADD  CONSTRAINT [StudentInterventionAttendanceEvent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent] ADD  CONSTRAINT [StudentInterventionAttendanceEvent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentLanguage] ADD  CONSTRAINT [StudentLanguage_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentLanguageUse] ADD  CONSTRAINT [StudentLanguageUse_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentLearningObjective] ADD  CONSTRAINT [StudentLearningObjective_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentLearningObjective] ADD  CONSTRAINT [StudentLearningObjective_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentLearningObjective] ADD  CONSTRAINT [StudentLearningObjective_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentLearningStyle] ADD  CONSTRAINT [StudentLearningStyle_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentOtherName] ADD  CONSTRAINT [StudentOtherName_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentParentAssociation] ADD  CONSTRAINT [StudentParentAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentParentAssociation] ADD  CONSTRAINT [StudentParentAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentParentAssociation] ADD  CONSTRAINT [StudentParentAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentParticipationCodeType] ADD  CONSTRAINT [StudentParticipationCodeType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentParticipationCodeType] ADD  CONSTRAINT [StudentParticipationCodeType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentParticipationCodeType] ADD  CONSTRAINT [StudentParticipationCodeType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentProgramAssociation] ADD  CONSTRAINT [StudentProgramAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentProgramAssociation] ADD  CONSTRAINT [StudentProgramAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentProgramAssociation] ADD  CONSTRAINT [StudentProgramAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentProgramAssociationService] ADD  CONSTRAINT [StudentProgramAssociationService_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent] ADD  CONSTRAINT [StudentProgramAttendanceEvent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent] ADD  CONSTRAINT [StudentProgramAttendanceEvent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent] ADD  CONSTRAINT [StudentProgramAttendanceEvent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentProgramParticipation] ADD  CONSTRAINT [StudentProgramParticipation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentProgramParticipationProgramCharacteristic] ADD  CONSTRAINT [StudentProgramParticipationProgramCharacteristic_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentRace] ADD  CONSTRAINT [StudentRace_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] ADD  CONSTRAINT [StudentSchoolAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] ADD  CONSTRAINT [StudentSchoolAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] ADD  CONSTRAINT [StudentSchoolAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentSchoolAssociationEducationPlan] ADD  CONSTRAINT [StudentSchoolAssociationEducationPlan_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent] ADD  CONSTRAINT [StudentSchoolAttendanceEvent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent] ADD  CONSTRAINT [StudentSchoolAttendanceEvent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent] ADD  CONSTRAINT [StudentSchoolAttendanceEvent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentSectionAssociation] ADD  CONSTRAINT [StudentSectionAssociation_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentSectionAssociation] ADD  CONSTRAINT [StudentSectionAssociation_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentSectionAssociation] ADD  CONSTRAINT [StudentSectionAssociation_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent] ADD  CONSTRAINT [StudentSectionAttendanceEvent_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent] ADD  CONSTRAINT [StudentSectionAttendanceEvent_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent] ADD  CONSTRAINT [StudentSectionAttendanceEvent_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentSpecialEducationProgramAssociationServiceProvider] ADD  CONSTRAINT [StudentSpecialEducationProgramAssociationServiceProvider_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentTelephone] ADD  CONSTRAINT [StudentTelephone_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[StudentVisa] ADD  CONSTRAINT [StudentVisa_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[TeachingCredentialBasisType] ADD  CONSTRAINT [TeachingCredentialBasisType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[TeachingCredentialBasisType] ADD  CONSTRAINT [TeachingCredentialBasisType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[TeachingCredentialBasisType] ADD  CONSTRAINT [TeachingCredentialBasisType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[TeachingCredentialType] ADD  CONSTRAINT [TeachingCredentialType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[TeachingCredentialType] ADD  CONSTRAINT [TeachingCredentialType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[TeachingCredentialType] ADD  CONSTRAINT [TeachingCredentialType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[TelephoneNumberType] ADD  CONSTRAINT [TelephoneNumberType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[TelephoneNumberType] ADD  CONSTRAINT [TelephoneNumberType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[TelephoneNumberType] ADD  CONSTRAINT [TelephoneNumberType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[TermType] ADD  CONSTRAINT [TermType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[TermType] ADD  CONSTRAINT [TermType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[TermType] ADD  CONSTRAINT [TermType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[TitleIPartAParticipantType] ADD  CONSTRAINT [TitleIPartAParticipantType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[TitleIPartAParticipantType] ADD  CONSTRAINT [TitleIPartAParticipantType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[TitleIPartAParticipantType] ADD  CONSTRAINT [TitleIPartAParticipantType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[TitleIPartASchoolDesignationType] ADD  CONSTRAINT [TitleIPartASchoolDesignationType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[TitleIPartASchoolDesignationType] ADD  CONSTRAINT [TitleIPartASchoolDesignationType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[TitleIPartASchoolDesignationType] ADD  CONSTRAINT [TitleIPartASchoolDesignationType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[VisaType] ADD  CONSTRAINT [VisaType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[VisaType] ADD  CONSTRAINT [VisaType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[VisaType] ADD  CONSTRAINT [VisaType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [edfi].[WeaponType] ADD  CONSTRAINT [WeaponType_DF_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [edfi].[WeaponType] ADD  CONSTRAINT [WeaponType_DF_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
GO
ALTER TABLE [edfi].[WeaponType] ADD  CONSTRAINT [WeaponType_DF_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [util].[EdFiSanity] ADD  CONSTRAINT [EdFiSanity_DF_Script]  DEFAULT ('') FOR [Script]
GO
ALTER TABLE [util].[EdFiSanity] ADD  CONSTRAINT [EdFiSanity_DF_ParserCompletionFlag]  DEFAULT ((0)) FOR [ParserCompletionFlag]
GO
ALTER TABLE [util].[EdFiSanity] ADD  CONSTRAINT [EdFiSanity_DF_ExecCompletionFlag]  DEFAULT ((0)) FOR [ExecCompletionFlag]
GO
ALTER TABLE [util].[QAResults] ADD  CONSTRAINT [QAResults_DF_CreateDateTime]  DEFAULT (getdate()) FOR [CreateDateTime]
GO
ALTER TABLE [EASOL].[DashboardConfiguration]  WITH CHECK ADD  CONSTRAINT [FK__Dashboard__Botto__5C4299A5] FOREIGN KEY([BottomTableReportId])
REFERENCES [EASOL].[Report] ([ReportId])
GO
ALTER TABLE [EASOL].[DashboardConfiguration] CHECK CONSTRAINT [FK__Dashboard__Botto__5C4299A5]
GO
ALTER TABLE [EASOL].[DashboardConfiguration]  WITH CHECK ADD FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [EASOL].[DashboardConfiguration]  WITH CHECK ADD  CONSTRAINT [FK__Dashboard__LeftC__5E2AE217] FOREIGN KEY([LeftChartReportId])
REFERENCES [EASOL].[Report] ([ReportId])
GO
ALTER TABLE [EASOL].[DashboardConfiguration] CHECK CONSTRAINT [FK__Dashboard__LeftC__5E2AE217]
GO
ALTER TABLE [EASOL].[DashboardConfiguration]  WITH CHECK ADD  CONSTRAINT [FK__Dashboard__Right__5F1F0650] FOREIGN KEY([RightChartReportId])
REFERENCES [EASOL].[Report] ([ReportId])
GO
ALTER TABLE [EASOL].[DashboardConfiguration] CHECK CONSTRAINT [FK__Dashboard__Right__5F1F0650]
GO
ALTER TABLE [EASOL].[DashboardConfiguration]  WITH CHECK ADD FOREIGN KEY([RoleTypeId])
REFERENCES [EASOL].[RoleType] ([RoleTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [EASOL].[StaffAuthentication]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [EASOL].[RoleType] ([RoleTypeId])
ON DELETE SET NULL
GO
ALTER TABLE [EASOL].[StaffAuthentication]  WITH CHECK ADD  CONSTRAINT [FK__StaffAuth__Staff__06E2DEE6] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [EASOL].[StaffAuthentication] CHECK CONSTRAINT [FK__StaffAuth__Staff__06E2DEE6]
GO
ALTER TABLE [edfi].[AcademicSubjectDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AcademicSubjectDescriptor_AcademicSubjectType_AcademicSubjectTypeId] FOREIGN KEY([AcademicSubjectTypeId])
REFERENCES [edfi].[AcademicSubjectType] ([AcademicSubjectTypeId])
GO
ALTER TABLE [edfi].[AcademicSubjectDescriptor] CHECK CONSTRAINT [FK_AcademicSubjectDescriptor_AcademicSubjectType_AcademicSubjectTypeId]
GO
ALTER TABLE [edfi].[AcademicSubjectDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AcademicSubjectDescriptor_Descriptor_DescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AcademicSubjectDescriptor] CHECK CONSTRAINT [FK_AcademicSubjectDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[AcademicWeek]  WITH NOCHECK ADD  CONSTRAINT [FK_AcademicWeek_CalendarDate_BeginDate] FOREIGN KEY([EducationOrganizationId], [BeginDate])
REFERENCES [edfi].[CalendarDate] ([EducationOrganizationId], [Date])
GO
ALTER TABLE [edfi].[AcademicWeek] CHECK CONSTRAINT [FK_AcademicWeek_CalendarDate_BeginDate]
GO
ALTER TABLE [edfi].[AcademicWeek]  WITH NOCHECK ADD  CONSTRAINT [FK_AcademicWeek_CalendarDate_EndDate] FOREIGN KEY([EducationOrganizationId], [EndDate])
REFERENCES [edfi].[CalendarDate] ([EducationOrganizationId], [Date])
GO
ALTER TABLE [edfi].[AcademicWeek] CHECK CONSTRAINT [FK_AcademicWeek_CalendarDate_EndDate]
GO
ALTER TABLE [edfi].[AccommodationDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AccommodationDescriptor_AccommodationType_AccommodationTypeId] FOREIGN KEY([AccommodationTypeId])
REFERENCES [edfi].[AccommodationType] ([AccommodationTypeId])
GO
ALTER TABLE [edfi].[AccommodationDescriptor] CHECK CONSTRAINT [FK_AccommodationDescriptor_AccommodationType_AccommodationTypeId]
GO
ALTER TABLE [edfi].[AccommodationDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AccommodationDescriptor_Descriptor_DescriptorId] FOREIGN KEY([AccommodationDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AccommodationDescriptor] CHECK CONSTRAINT [FK_AccommodationDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[Account]  WITH NOCHECK ADD  CONSTRAINT [FK_Account_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[Account] CHECK CONSTRAINT [FK_Account_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[AccountabilityRating]  WITH NOCHECK ADD  CONSTRAINT [FK_AccountabilityRating_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[AccountabilityRating] CHECK CONSTRAINT [FK_AccountabilityRating_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[AccountabilityRating]  WITH NOCHECK ADD  CONSTRAINT [FK_AccountabilityRating_SchoolYearType_SchoolYear] FOREIGN KEY([SchoolYear])
REFERENCES [edfi].[SchoolYearType] ([SchoolYear])
GO
ALTER TABLE [edfi].[AccountabilityRating] CHECK CONSTRAINT [FK_AccountabilityRating_SchoolYearType_SchoolYear]
GO
ALTER TABLE [edfi].[AccountCode]  WITH NOCHECK ADD  CONSTRAINT [FK_AccountCode_Account_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [AccountNumber], [FiscalYear])
REFERENCES [edfi].[Account] ([EducationOrganizationId], [AccountNumber], [FiscalYear])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AccountCode] CHECK CONSTRAINT [FK_AccountCode_Account_EducationOrganizationId]
GO
ALTER TABLE [edfi].[AccountCode]  WITH NOCHECK ADD  CONSTRAINT [FK_AccountCode_AccountCodeDescriptor_AccountCodeDescriptorId] FOREIGN KEY([AccountCodeDescriptorId])
REFERENCES [edfi].[AccountCodeDescriptor] ([AccountCodeDescriptorId])
GO
ALTER TABLE [edfi].[AccountCode] CHECK CONSTRAINT [FK_AccountCode_AccountCodeDescriptor_AccountCodeDescriptorId]
GO
ALTER TABLE [edfi].[AccountCodeDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AccountCodeDescriptor_Descriptor_DescriptorId] FOREIGN KEY([AccountCodeDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AccountCodeDescriptor] CHECK CONSTRAINT [FK_AccountCodeDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[AchievementCategoryDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AchievementCategoryDescriptor_AchievementCategoryType_AchievementCategoryTypeId] FOREIGN KEY([AchievementCategoryTypeId])
REFERENCES [edfi].[AchievementCategoryType] ([AchievementCategoryTypeId])
GO
ALTER TABLE [edfi].[AchievementCategoryDescriptor] CHECK CONSTRAINT [FK_AchievementCategoryDescriptor_AchievementCategoryType_AchievementCategoryTypeId]
GO
ALTER TABLE [edfi].[AchievementCategoryDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AchievementCategoryDescriptor_Descriptor_DescriptorId] FOREIGN KEY([AchievementCategoryDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AchievementCategoryDescriptor] CHECK CONSTRAINT [FK_AchievementCategoryDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[Actual]  WITH NOCHECK ADD  CONSTRAINT [FK_Actual_Account_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [AccountNumber], [FiscalYear])
REFERENCES [edfi].[Account] ([EducationOrganizationId], [AccountNumber], [FiscalYear])
GO
ALTER TABLE [edfi].[Actual] CHECK CONSTRAINT [FK_Actual_Account_EducationOrganizationId]
GO
ALTER TABLE [edfi].[AdministrativeFundingControlDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AdministrativeFundingControlDescriptor_AdministrativeFundingControlType_AdministrativeFundingControlTypeId] FOREIGN KEY([AdministrativeFundingControlTypeId])
REFERENCES [edfi].[AdministrativeFundingControlType] ([AdministrativeFundingControlTypeId])
GO
ALTER TABLE [edfi].[AdministrativeFundingControlDescriptor] CHECK CONSTRAINT [FK_AdministrativeFundingControlDescriptor_AdministrativeFundingControlType_AdministrativeFundingControlTypeId]
GO
ALTER TABLE [edfi].[AdministrativeFundingControlDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AdministrativeFundingControlDescriptor_Descriptor_DescriptorId] FOREIGN KEY([AdministrativeFundingControlDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AdministrativeFundingControlDescriptor] CHECK CONSTRAINT [FK_AdministrativeFundingControlDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[Assessment]  WITH NOCHECK ADD  CONSTRAINT [FK_Assessment_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[Assessment] CHECK CONSTRAINT [FK_Assessment_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[Assessment]  WITH NOCHECK ADD  CONSTRAINT [FK_Assessment_AssessedGradeLevelDescriptorId] FOREIGN KEY([AssessedGradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[Assessment] CHECK CONSTRAINT [FK_Assessment_AssessedGradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[Assessment]  WITH NOCHECK ADD  CONSTRAINT [FK_Assessment_AssessmentCategoryType_AssessmentCategoryTypeId] FOREIGN KEY([AssessmentCategoryTypeId])
REFERENCES [edfi].[AssessmentCategoryType] ([AssessmentCategoryTypeId])
GO
ALTER TABLE [edfi].[Assessment] CHECK CONSTRAINT [FK_Assessment_AssessmentCategoryType_AssessmentCategoryTypeId]
GO
ALTER TABLE [edfi].[Assessment]  WITH NOCHECK ADD  CONSTRAINT [FK_Assessment_AssessmentFamily] FOREIGN KEY([AssessmentFamilyTitle])
REFERENCES [edfi].[AssessmentFamily] ([AssessmentFamilyTitle])
GO
ALTER TABLE [edfi].[Assessment] CHECK CONSTRAINT [FK_Assessment_AssessmentFamily]
GO
ALTER TABLE [edfi].[Assessment]  WITH NOCHECK ADD  CONSTRAINT [FK_Assessment_AssessmentPeriodDescriptor_AssessmentPeriodDescriptorId] FOREIGN KEY([AssessmentPeriodDescriptorId])
REFERENCES [edfi].[AssessmentPeriodDescriptor] ([AssessmentPeriodDescriptorId])
GO
ALTER TABLE [edfi].[Assessment] CHECK CONSTRAINT [FK_Assessment_AssessmentPeriodDescriptor_AssessmentPeriodDescriptorId]
GO
ALTER TABLE [edfi].[Assessment]  WITH NOCHECK ADD  CONSTRAINT [FK_Assessment_LowestAssessedGradeLevelDescriptorId] FOREIGN KEY([LowestAssessedGradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[Assessment] CHECK CONSTRAINT [FK_Assessment_LowestAssessedGradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[AssessmentContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentContentStandard_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [AssessmentVersion])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentContentStandard] CHECK CONSTRAINT [FK_AssessmentContentStandard_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[AssessmentContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentContentStandard_EducationOrganization_MandatingEducationOrganizationId] FOREIGN KEY([MandatingEducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[AssessmentContentStandard] CHECK CONSTRAINT [FK_AssessmentContentStandard_EducationOrganization_MandatingEducationOrganizationId]
GO
ALTER TABLE [edfi].[AssessmentContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentContentStandard_PublicationStatusType_PublicationStatusTypeId] FOREIGN KEY([PublicationStatusTypeId])
REFERENCES [edfi].[PublicationStatusType] ([PublicationStatusTypeId])
GO
ALTER TABLE [edfi].[AssessmentContentStandard] CHECK CONSTRAINT [FK_AssessmentContentStandard_PublicationStatusType_PublicationStatusTypeId]
GO
ALTER TABLE [edfi].[AssessmentContentStandardAuthor]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentContentStandardAuthor_AssessmentContentStandard_AssessmentTitle] FOREIGN KEY([AssessmentVersion], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId])
REFERENCES [edfi].[AssessmentContentStandard] ([AssessmentVersion], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentContentStandardAuthor] CHECK CONSTRAINT [FK_AssessmentContentStandardAuthor_AssessmentContentStandard_AssessmentTitle]
GO
ALTER TABLE [edfi].[AssessmentFamily]  WITH CHECK ADD  CONSTRAINT [FK_AssessmentFamily_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[AssessmentFamily] CHECK CONSTRAINT [FK_AssessmentFamily_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[AssessmentFamily]  WITH CHECK ADD  CONSTRAINT [FK_AssessmentFamily_AssessedGradeLevelDescriptorId] FOREIGN KEY([AssessedGradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[AssessmentFamily] CHECK CONSTRAINT [FK_AssessmentFamily_AssessedGradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[AssessmentFamily]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamily_AssessmentCategoryType_AssessmentCategoryTypeId] FOREIGN KEY([AssessmentCategoryTypeId])
REFERENCES [edfi].[AssessmentCategoryType] ([AssessmentCategoryTypeId])
GO
ALTER TABLE [edfi].[AssessmentFamily] CHECK CONSTRAINT [FK_AssessmentFamily_AssessmentCategoryType_AssessmentCategoryTypeId]
GO
ALTER TABLE [edfi].[AssessmentFamily]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamily_AssessmentFamily_ParentAssessmentFamilyTitle] FOREIGN KEY([ParentAssessmentFamilyTitle])
REFERENCES [edfi].[AssessmentFamily] ([AssessmentFamilyTitle])
GO
ALTER TABLE [edfi].[AssessmentFamily] CHECK CONSTRAINT [FK_AssessmentFamily_AssessmentFamily_ParentAssessmentFamilyTitle]
GO
ALTER TABLE [edfi].[AssessmentFamily]  WITH CHECK ADD  CONSTRAINT [FK_AssessmentFamily_LowestAssessedGradeLevelDescriptorId] FOREIGN KEY([LowestAssessedGradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[AssessmentFamily] CHECK CONSTRAINT [FK_AssessmentFamily_LowestAssessedGradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[AssessmentFamilyAssessmentPeriod]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamilyAssessmentPeriod_AssessmentFamily_AssessmentFamilyTitle] FOREIGN KEY([AssessmentFamilyTitle])
REFERENCES [edfi].[AssessmentFamily] ([AssessmentFamilyTitle])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentFamilyAssessmentPeriod] CHECK CONSTRAINT [FK_AssessmentFamilyAssessmentPeriod_AssessmentFamily_AssessmentFamilyTitle]
GO
ALTER TABLE [edfi].[AssessmentFamilyAssessmentPeriod]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamilyAssessmentPeriod_AssessmentPeriodDescriptor_AssessmentPeriodDescriptorId] FOREIGN KEY([AssessmentPeriodDescriptorId])
REFERENCES [edfi].[AssessmentPeriodDescriptor] ([AssessmentPeriodDescriptorId])
GO
ALTER TABLE [edfi].[AssessmentFamilyAssessmentPeriod] CHECK CONSTRAINT [FK_AssessmentFamilyAssessmentPeriod_AssessmentPeriodDescriptor_AssessmentPeriodDescriptorId]
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamilyContentStandard_AssessmentFamily_AssessmentFamilyTitle] FOREIGN KEY([AssessmentFamilyTitle])
REFERENCES [edfi].[AssessmentFamily] ([AssessmentFamilyTitle])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandard] CHECK CONSTRAINT [FK_AssessmentFamilyContentStandard_AssessmentFamily_AssessmentFamilyTitle]
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamilyContentStandard_EducationOrganization_MandatingEducationOrganizationId] FOREIGN KEY([MandatingEducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandard] CHECK CONSTRAINT [FK_AssessmentFamilyContentStandard_EducationOrganization_MandatingEducationOrganizationId]
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamilyContentStandard_PublicationStatusType_PublicationStatusTypeId] FOREIGN KEY([PublicationStatusTypeId])
REFERENCES [edfi].[PublicationStatusType] ([PublicationStatusTypeId])
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandard] CHECK CONSTRAINT [FK_AssessmentFamilyContentStandard_PublicationStatusType_PublicationStatusTypeId]
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandardAuthor]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamilyContentStandardAuthor_AssessmentFamilyContentStandard_AssessmentFamilyTitle] FOREIGN KEY([AssessmentFamilyTitle])
REFERENCES [edfi].[AssessmentFamilyContentStandard] ([AssessmentFamilyTitle])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentFamilyContentStandardAuthor] CHECK CONSTRAINT [FK_AssessmentFamilyContentStandardAuthor_AssessmentFamilyContentStandard_AssessmentFamilyTitle]
GO
ALTER TABLE [edfi].[AssessmentFamilyIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamilyIdentificationCode_AssessmentFamily_AssessmentFamilyTitle] FOREIGN KEY([AssessmentFamilyTitle])
REFERENCES [edfi].[AssessmentFamily] ([AssessmentFamilyTitle])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentFamilyIdentificationCode] CHECK CONSTRAINT [FK_AssessmentFamilyIdentificationCode_AssessmentFamily_AssessmentFamilyTitle]
GO
ALTER TABLE [edfi].[AssessmentFamilyIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamilyIdentificationCode_AssessmentIdentificationSystemType_AssessmentIdentificationSystemTypeId] FOREIGN KEY([AssessmentIdentificationSystemTypeId])
REFERENCES [edfi].[AssessmentIdentificationSystemType] ([AssessmentIdentificationSystemTypeId])
GO
ALTER TABLE [edfi].[AssessmentFamilyIdentificationCode] CHECK CONSTRAINT [FK_AssessmentFamilyIdentificationCode_AssessmentIdentificationSystemType_AssessmentIdentificationSystemTypeId]
GO
ALTER TABLE [edfi].[AssessmentFamilyLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamiliyLanguages_AssessmentFamily_AssessmentFamilyTitle] FOREIGN KEY([AssessmentFamilyTitle])
REFERENCES [edfi].[AssessmentFamily] ([AssessmentFamilyTitle])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentFamilyLanguage] CHECK CONSTRAINT [FK_AssessmentFamiliyLanguages_AssessmentFamily_AssessmentFamilyTitle]
GO
ALTER TABLE [edfi].[AssessmentFamilyLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentFamilyLanguages_LanguageDescriptor_LanguageDescriptorId] FOREIGN KEY([LanguageDescriptorId])
REFERENCES [edfi].[LanguageDescriptor] ([LanguageDescriptorId])
GO
ALTER TABLE [edfi].[AssessmentFamilyLanguage] CHECK CONSTRAINT [FK_AssessmentFamilyLanguages_LanguageDescriptor_LanguageDescriptorId]
GO
ALTER TABLE [edfi].[AssessmentIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentIdentificationCode_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentIdentificationCode] CHECK CONSTRAINT [FK_AssessmentIdentificationCode_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[AssessmentIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentIdentificationCode_AssessmentIdentificationSystemType_AssessmentIdentificationSystemTypeId] FOREIGN KEY([AssessmentIdentificationSystemTypeId])
REFERENCES [edfi].[AssessmentIdentificationSystemType] ([AssessmentIdentificationSystemTypeId])
GO
ALTER TABLE [edfi].[AssessmentIdentificationCode] CHECK CONSTRAINT [FK_AssessmentIdentificationCode_AssessmentIdentificationSystemType_AssessmentIdentificationSystemTypeId]
GO
ALTER TABLE [edfi].[AssessmentItem]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentItem_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
GO
ALTER TABLE [edfi].[AssessmentItem] CHECK CONSTRAINT [FK_AssessmentItem_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[AssessmentItem]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentItem_AssessmentItemCategoryType_AssessmentItemCategoryTypeId] FOREIGN KEY([AssessmentItemCategoryTypeId])
REFERENCES [edfi].[AssessmentItemCategoryType] ([AssessmentItemCategoryTypeId])
GO
ALTER TABLE [edfi].[AssessmentItem] CHECK CONSTRAINT [FK_AssessmentItem_AssessmentItemCategoryType_AssessmentItemCategoryTypeId]
GO
ALTER TABLE [edfi].[AssessmentItemLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentItemLearningStandard_AssessmentItem] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
REFERENCES [edfi].[AssessmentItem] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentItemLearningStandard] CHECK CONSTRAINT [FK_AssessmentItemLearningStandard_AssessmentItem]
GO
ALTER TABLE [edfi].[AssessmentItemLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentItemLearningStandard_LearningStandard_LearningStandardId] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
GO
ALTER TABLE [edfi].[AssessmentItemLearningStandard] CHECK CONSTRAINT [FK_AssessmentItemLearningStandard_LearningStandard_LearningStandardId]
GO
ALTER TABLE [edfi].[AssessmentLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentLanguages_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentLanguage] CHECK CONSTRAINT [FK_AssessmentLanguages_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[AssessmentLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentLanguages_LanguageDescriptor_LanguageDescriptorId] FOREIGN KEY([LanguageDescriptorId])
REFERENCES [edfi].[LanguageDescriptor] ([LanguageDescriptorId])
GO
ALTER TABLE [edfi].[AssessmentLanguage] CHECK CONSTRAINT [FK_AssessmentLanguages_LanguageDescriptor_LanguageDescriptorId]
GO
ALTER TABLE [edfi].[AssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentPerformanceLevel_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentPerformanceLevel] CHECK CONSTRAINT [FK_AssessmentPerformanceLevel_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[AssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentPerformanceLevel_AssessmentReportingMethodType_AssessmentReportingMethodTypeId] FOREIGN KEY([AssessmentReportingMethodTypeId])
REFERENCES [edfi].[AssessmentReportingMethodType] ([AssessmentReportingMethodTypeId])
GO
ALTER TABLE [edfi].[AssessmentPerformanceLevel] CHECK CONSTRAINT [FK_AssessmentPerformanceLevel_AssessmentReportingMethodType_AssessmentReportingMethodTypeId]
GO
ALTER TABLE [edfi].[AssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentPerformanceLevel_PerformanceLevelDescriptor_PerformanceLevelDescriptorId] FOREIGN KEY([PerformanceLevelDescriptorId])
REFERENCES [edfi].[PerformanceLevelDescriptor] ([PerformanceLevelDescriptorId])
GO
ALTER TABLE [edfi].[AssessmentPerformanceLevel] CHECK CONSTRAINT [FK_AssessmentPerformanceLevel_PerformanceLevelDescriptor_PerformanceLevelDescriptorId]
GO
ALTER TABLE [edfi].[AssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentPerformanceLevel_ResultDatatypeType_ResultDatatypeTypeId] FOREIGN KEY([ResultDatatypeTypeId])
REFERENCES [edfi].[ResultDatatypeType] ([ResultDatatypeTypeId])
GO
ALTER TABLE [edfi].[AssessmentPerformanceLevel] CHECK CONSTRAINT [FK_AssessmentPerformanceLevel_ResultDatatypeType_ResultDatatypeTypeId]
GO
ALTER TABLE [edfi].[AssessmentPeriodDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentPeriodDescriptor_Descriptor_DescriptorId] FOREIGN KEY([AssessmentPeriodDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentPeriodDescriptor] CHECK CONSTRAINT [FK_AssessmentPeriodDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[AssessmentProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentProgram_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentProgram] CHECK CONSTRAINT [FK_AssessmentProgram_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[AssessmentProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentProgram_Program_ProgramTypeId] FOREIGN KEY([EducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
GO
ALTER TABLE [edfi].[AssessmentProgram] CHECK CONSTRAINT [FK_AssessmentProgram_Program_ProgramTypeId]
GO
ALTER TABLE [edfi].[AssessmentScore]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentScore_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentScore] CHECK CONSTRAINT [FK_AssessmentScore_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[AssessmentScore]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentScore_AssessmentReportingMethodType_AssessmentReportingMethodTypeId] FOREIGN KEY([AssessmentReportingMethodTypeId])
REFERENCES [edfi].[AssessmentReportingMethodType] ([AssessmentReportingMethodTypeId])
GO
ALTER TABLE [edfi].[AssessmentScore] CHECK CONSTRAINT [FK_AssessmentScore_AssessmentReportingMethodType_AssessmentReportingMethodTypeId]
GO
ALTER TABLE [edfi].[AssessmentScore]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentScore_ResultDatatypeType_ResultDatatypeTypeId] FOREIGN KEY([ResultDatatypeTypeId])
REFERENCES [edfi].[ResultDatatypeType] ([ResultDatatypeTypeId])
GO
ALTER TABLE [edfi].[AssessmentScore] CHECK CONSTRAINT [FK_AssessmentScore_ResultDatatypeType_ResultDatatypeTypeId]
GO
ALTER TABLE [edfi].[AssessmentSection]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentSection_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AssessmentSection] CHECK CONSTRAINT [FK_AssessmentSection_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[AssessmentSection]  WITH NOCHECK ADD  CONSTRAINT [FK_AssessmentSection_Section_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Section] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[AssessmentSection] CHECK CONSTRAINT [FK_AssessmentSection_Section_SchoolId]
GO
ALTER TABLE [edfi].[AttendanceEventCategoryDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AttendanceEventCategoryDescriptor_AttendanceEventCategoryType_AttendanceEventCategoryTypeId] FOREIGN KEY([AttendanceEventCategoryTypeId])
REFERENCES [edfi].[AttendanceEventCategoryType] ([AttendanceEventCategoryTypeId])
GO
ALTER TABLE [edfi].[AttendanceEventCategoryDescriptor] CHECK CONSTRAINT [FK_AttendanceEventCategoryDescriptor_AttendanceEventCategoryType_AttendanceEventCategoryTypeId]
GO
ALTER TABLE [edfi].[AttendanceEventCategoryDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_AttendanceEventCategoryDescriptor_Descriptor_DescriptorId] FOREIGN KEY([AttendanceEventCategoryDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[AttendanceEventCategoryDescriptor] CHECK CONSTRAINT [FK_AttendanceEventCategoryDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[BehaviorDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_BehaviorDescriptor_BehaviorType_BehaviorTypeId] FOREIGN KEY([BehaviorTypeId])
REFERENCES [edfi].[BehaviorType] ([BehaviorTypeId])
GO
ALTER TABLE [edfi].[BehaviorDescriptor] CHECK CONSTRAINT [FK_BehaviorDescriptor_BehaviorType_BehaviorTypeId]
GO
ALTER TABLE [edfi].[BehaviorDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_BehaviorDescriptor_Descriptor_DescriptorId] FOREIGN KEY([BehaviorDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[BehaviorDescriptor] CHECK CONSTRAINT [FK_BehaviorDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[BellSchedule]  WITH NOCHECK ADD  CONSTRAINT [FK_BellSchedule_CalendarDate_Date] FOREIGN KEY([SchoolId], [Date])
REFERENCES [edfi].[CalendarDate] ([EducationOrganizationId], [Date])
GO
ALTER TABLE [edfi].[BellSchedule] CHECK CONSTRAINT [FK_BellSchedule_CalendarDate_Date]
GO
ALTER TABLE [edfi].[BellSchedule]  WITH CHECK ADD  CONSTRAINT [FK_BellSchedule_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[BellSchedule] CHECK CONSTRAINT [FK_BellSchedule_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[BellSchedule]  WITH NOCHECK ADD  CONSTRAINT [FK_BellSchedule_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[BellSchedule] CHECK CONSTRAINT [FK_BellSchedule_School_SchoolId]
GO
ALTER TABLE [edfi].[BellScheduleMeetingTime]  WITH NOCHECK ADD  CONSTRAINT [FK_BellScheduleMeetingTime_BellSchedule] FOREIGN KEY([SchoolId], [GradeLevelDescriptorId], [Date], [BellScheduleName])
REFERENCES [edfi].[BellSchedule] ([SchoolId], [GradeLevelDescriptorId], [Date], [BellScheduleName])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[BellScheduleMeetingTime] CHECK CONSTRAINT [FK_BellScheduleMeetingTime_BellSchedule]
GO
ALTER TABLE [edfi].[BellScheduleMeetingTime]  WITH NOCHECK ADD  CONSTRAINT [FK_BellScheduleMeetingTime_ClassPeriod] FOREIGN KEY([SchoolId], [ClassPeriodName])
REFERENCES [edfi].[ClassPeriod] ([SchoolId], [ClassPeriodName])
GO
ALTER TABLE [edfi].[BellScheduleMeetingTime] CHECK CONSTRAINT [FK_BellScheduleMeetingTime_ClassPeriod]
GO
ALTER TABLE [edfi].[Budget]  WITH NOCHECK ADD  CONSTRAINT [FK_Budget_Account_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [AccountNumber], [FiscalYear])
REFERENCES [edfi].[Account] ([EducationOrganizationId], [AccountNumber], [FiscalYear])
GO
ALTER TABLE [edfi].[Budget] CHECK CONSTRAINT [FK_Budget_Account_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CalendarDate]  WITH NOCHECK ADD  CONSTRAINT [FK_CalendarDate_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[CalendarDate] CHECK CONSTRAINT [FK_CalendarDate_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CalendarDateCalendarEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_CalendarDateCalendarEvent_CalendarDate] FOREIGN KEY([EducationOrganizationId], [Date])
REFERENCES [edfi].[CalendarDate] ([EducationOrganizationId], [Date])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CalendarDateCalendarEvent] CHECK CONSTRAINT [FK_CalendarDateCalendarEvent_CalendarDate]
GO
ALTER TABLE [edfi].[CalendarDateCalendarEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_CalendarDateCalendarEvent_CalendarEventDescriptor_CalendarEventDescriptorId] FOREIGN KEY([CalendarEventDescriptorId])
REFERENCES [edfi].[CalendarEventDescriptor] ([CalendarEventDescriptorId])
GO
ALTER TABLE [edfi].[CalendarDateCalendarEvent] CHECK CONSTRAINT [FK_CalendarDateCalendarEvent_CalendarEventDescriptor_CalendarEventDescriptorId]
GO
ALTER TABLE [edfi].[CalendarEventDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_CalendarEventDescriptor_CalendarEventType_CalendarEventTypeId] FOREIGN KEY([CalendarEventTypeId])
REFERENCES [edfi].[CalendarEventType] ([CalendarEventTypeId])
GO
ALTER TABLE [edfi].[CalendarEventDescriptor] CHECK CONSTRAINT [FK_CalendarEventDescriptor_CalendarEventType_CalendarEventTypeId]
GO
ALTER TABLE [edfi].[CalendarEventDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_CalendarEventDescriptor_Descriptor_DescriptorId] FOREIGN KEY([CalendarEventDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CalendarEventDescriptor] CHECK CONSTRAINT [FK_CalendarEventDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[ClassPeriod]  WITH NOCHECK ADD  CONSTRAINT [FK_ClassPeriod_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[ClassPeriod] CHECK CONSTRAINT [FK_ClassPeriod_School_SchoolId]
GO
ALTER TABLE [edfi].[ClassroomPositionDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ClassroomPositionDescriptor_ClassroomPositionType_ClassroomPositionTypeId] FOREIGN KEY([ClassroomPositionTypeId])
REFERENCES [edfi].[ClassroomPositionType] ([ClassroomPositionTypeId])
GO
ALTER TABLE [edfi].[ClassroomPositionDescriptor] CHECK CONSTRAINT [FK_ClassroomPositionDescriptor_ClassroomPositionType_ClassroomPositionTypeId]
GO
ALTER TABLE [edfi].[ClassroomPositionDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ClassroomPositionDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ClassroomPositionDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ClassroomPositionDescriptor] CHECK CONSTRAINT [FK_ClassroomPositionDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[Cohort]  WITH CHECK ADD  CONSTRAINT [FK_Cohort_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[Cohort] CHECK CONSTRAINT [FK_Cohort_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[Cohort]  WITH NOCHECK ADD  CONSTRAINT [FK_Cohort_CohortScopeType_CohortScopeTypeId] FOREIGN KEY([CohortScopeTypeId])
REFERENCES [edfi].[CohortScopeType] ([CohortScopeTypeId])
GO
ALTER TABLE [edfi].[Cohort] CHECK CONSTRAINT [FK_Cohort_CohortScopeType_CohortScopeTypeId]
GO
ALTER TABLE [edfi].[Cohort]  WITH NOCHECK ADD  CONSTRAINT [FK_Cohort_CohortType_CohortTypeId] FOREIGN KEY([CohortTypeId])
REFERENCES [edfi].[CohortType] ([CohortTypeId])
GO
ALTER TABLE [edfi].[Cohort] CHECK CONSTRAINT [FK_Cohort_CohortType_CohortTypeId]
GO
ALTER TABLE [edfi].[Cohort]  WITH NOCHECK ADD  CONSTRAINT [FK_Cohort_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[Cohort] CHECK CONSTRAINT [FK_Cohort_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CohortProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_CohortProgram_Cohort_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CohortIdentifier])
REFERENCES [edfi].[Cohort] ([EducationOrganizationId], [CohortIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CohortProgram] CHECK CONSTRAINT [FK_CohortProgram_Cohort_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CohortProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_CohortProgram_Program_EducationOrganizationId] FOREIGN KEY([ProgramEducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
GO
ALTER TABLE [edfi].[CohortProgram] CHECK CONSTRAINT [FK_CohortProgram_Program_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CompetencyLevelDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_CompetencyLevelDescriptor_Descriptor_DescriptorId] FOREIGN KEY([CompetencyLevelDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CompetencyLevelDescriptor] CHECK CONSTRAINT [FK_CompetencyLevelDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[CompetencyLevelDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_CompetencyLevelDescriptor_PerformanceBaseType_PerformanceBaseConversionTypeId] FOREIGN KEY([PerformanceBaseConversionTypeId])
REFERENCES [edfi].[PerformanceBaseConversionType] ([PerformanceBaseConversionTypeId])
GO
ALTER TABLE [edfi].[CompetencyLevelDescriptor] CHECK CONSTRAINT [FK_CompetencyLevelDescriptor_PerformanceBaseType_PerformanceBaseConversionTypeId]
GO
ALTER TABLE [edfi].[CompetencyObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_CompetencyObjective_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[CompetencyObjective] CHECK CONSTRAINT [FK_CompetencyObjective_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CompetencyObjective]  WITH CHECK ADD  CONSTRAINT [FK_CompetencyObjective_ObjectiveGradeLevelDescriptorId] FOREIGN KEY([ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[CompetencyObjective] CHECK CONSTRAINT [FK_CompetencyObjective_ObjectiveGradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[ContinuationOfServicesReasonDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ContinuationOfServicesReasonDescriptor_ContinuationOfServicesReasonType_ContinuationOfServicesReasonTypeId] FOREIGN KEY([ContinuationOfServicesReasonTypeId])
REFERENCES [edfi].[ContinuationOfServicesReasonType] ([ContinuationOfServicesReasonTypeId])
GO
ALTER TABLE [edfi].[ContinuationOfServicesReasonDescriptor] CHECK CONSTRAINT [FK_ContinuationOfServicesReasonDescriptor_ContinuationOfServicesReasonType_ContinuationOfServicesReasonTypeId]
GO
ALTER TABLE [edfi].[ContinuationOfServicesReasonDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ContinuationOfServicesReasonDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ContinuationOfServicesReasonDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ContinuationOfServicesReasonDescriptor] CHECK CONSTRAINT [FK_ContinuationOfServicesReasonDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[ContractedStaff]  WITH NOCHECK ADD  CONSTRAINT [FK_ContractedStaff_Account_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [AccountNumber], [FiscalYear])
REFERENCES [edfi].[Account] ([EducationOrganizationId], [AccountNumber], [FiscalYear])
GO
ALTER TABLE [edfi].[ContractedStaff] CHECK CONSTRAINT [FK_ContractedStaff_Account_EducationOrganizationId]
GO
ALTER TABLE [edfi].[ContractedStaff]  WITH NOCHECK ADD  CONSTRAINT [FK_ContractedStaff_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[ContractedStaff] CHECK CONSTRAINT [FK_ContractedStaff_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[Course]  WITH NOCHECK ADD  CONSTRAINT [FK_Course_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[Course] CHECK CONSTRAINT [FK_Course_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[Course]  WITH NOCHECK ADD  CONSTRAINT [FK_Course_CareerPathwayType_CareerPathwayTypeId] FOREIGN KEY([CareerPathwayTypeId])
REFERENCES [edfi].[CareerPathwayType] ([CareerPathwayTypeId])
GO
ALTER TABLE [edfi].[Course] CHECK CONSTRAINT [FK_Course_CareerPathwayType_CareerPathwayTypeId]
GO
ALTER TABLE [edfi].[Course]  WITH NOCHECK ADD  CONSTRAINT [FK_Course_CourseDefinedByType_CourseDefinedByTypeId] FOREIGN KEY([CourseDefinedByTypeId])
REFERENCES [edfi].[CourseDefinedByType] ([CourseDefinedByTypeId])
GO
ALTER TABLE [edfi].[Course] CHECK CONSTRAINT [FK_Course_CourseDefinedByType_CourseDefinedByTypeId]
GO
ALTER TABLE [edfi].[Course]  WITH NOCHECK ADD  CONSTRAINT [FK_Course_CourseGPAApplicabilityType_CourseGPAApplicabilityTypeId] FOREIGN KEY([CourseGPAApplicabilityTypeId])
REFERENCES [edfi].[CourseGPAApplicabilityType] ([CourseGPAApplicabilityTypeId])
GO
ALTER TABLE [edfi].[Course] CHECK CONSTRAINT [FK_Course_CourseGPAApplicabilityType_CourseGPAApplicabilityTypeId]
GO
ALTER TABLE [edfi].[Course]  WITH NOCHECK ADD  CONSTRAINT [FK_Course_CreditType_MaximumAvailableCreditTypeId] FOREIGN KEY([MaximumAvailableCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[Course] CHECK CONSTRAINT [FK_Course_CreditType_MaximumAvailableCreditTypeId]
GO
ALTER TABLE [edfi].[Course]  WITH NOCHECK ADD  CONSTRAINT [FK_Course_CreditType_MinimumAvailableCreditTypeId] FOREIGN KEY([MinimumAvailableCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[Course] CHECK CONSTRAINT [FK_Course_CreditType_MinimumAvailableCreditTypeId]
GO
ALTER TABLE [edfi].[Course]  WITH NOCHECK ADD  CONSTRAINT [FK_Course_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[Course] CHECK CONSTRAINT [FK_Course_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CourseCompetencyLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseCompetencyLevel_CompetencyLevelDescriptor_CompetencyLevelDescriptorId] FOREIGN KEY([CompetencyLevelDescriptorId])
REFERENCES [edfi].[CompetencyLevelDescriptor] ([CompetencyLevelDescriptorId])
GO
ALTER TABLE [edfi].[CourseCompetencyLevel] CHECK CONSTRAINT [FK_CourseCompetencyLevel_CompetencyLevelDescriptor_CompetencyLevelDescriptorId]
GO
ALTER TABLE [edfi].[CourseCompetencyLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseCompetencyLevel_Course_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CourseCode])
REFERENCES [edfi].[Course] ([EducationOrganizationId], [CourseCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CourseCompetencyLevel] CHECK CONSTRAINT [FK_CourseCompetencyLevel_Course_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CourseGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseGradeLevel_Course_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CourseCode])
REFERENCES [edfi].[Course] ([EducationOrganizationId], [CourseCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CourseGradeLevel] CHECK CONSTRAINT [FK_CourseGradeLevel_Course_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CourseGradeLevel]  WITH CHECK ADD  CONSTRAINT [FK_CourseGradeLevel_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[CourseGradeLevel] CHECK CONSTRAINT [FK_CourseGradeLevel_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[CourseIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseIdentificationCode_Course_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CourseCode])
REFERENCES [edfi].[Course] ([EducationOrganizationId], [CourseCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CourseIdentificationCode] CHECK CONSTRAINT [FK_CourseIdentificationCode_Course_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CourseIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseIdentificationCode_CourseCodeSystemType_CourseCodeSystemTypeId] FOREIGN KEY([CourseCodeSystemTypeId])
REFERENCES [edfi].[CourseCodeSystemType] ([CourseCodeSystemTypeId])
GO
ALTER TABLE [edfi].[CourseIdentificationCode] CHECK CONSTRAINT [FK_CourseIdentificationCode_CourseCodeSystemType_CourseCodeSystemTypeId]
GO
ALTER TABLE [edfi].[CourseLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseLearningObjective_Course_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CourseCode])
REFERENCES [edfi].[Course] ([EducationOrganizationId], [CourseCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CourseLearningObjective] CHECK CONSTRAINT [FK_CourseLearningObjective_Course_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CourseLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseLearningObjective_LearningObjective_Objective] FOREIGN KEY([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[LearningObjective] ([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[CourseLearningObjective] CHECK CONSTRAINT [FK_CourseLearningObjective_LearningObjective_Objective]
GO
ALTER TABLE [edfi].[CourseLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseLearningStandard_Course_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CourseCode])
REFERENCES [edfi].[Course] ([EducationOrganizationId], [CourseCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CourseLearningStandard] CHECK CONSTRAINT [FK_CourseLearningStandard_Course_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CourseLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseLearningStandard_LearningStandard_LearningStandardId] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
GO
ALTER TABLE [edfi].[CourseLearningStandard] CHECK CONSTRAINT [FK_CourseLearningStandard_LearningStandard_LearningStandardId]
GO
ALTER TABLE [edfi].[CourseLevelCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseLevelCharacteristics_Course_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CourseCode])
REFERENCES [edfi].[Course] ([EducationOrganizationId], [CourseCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CourseLevelCharacteristic] CHECK CONSTRAINT [FK_CourseLevelCharacteristics_Course_EducationOrganizationId]
GO
ALTER TABLE [edfi].[CourseLevelCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseLevelCharacteristics_CourseLevelCharacteristicsType_CourseLevelCharacteristicsTypeId] FOREIGN KEY([CourseLevelCharacteristicTypeId])
REFERENCES [edfi].[CourseLevelCharacteristicType] ([CourseLevelCharacteristicTypeId])
GO
ALTER TABLE [edfi].[CourseLevelCharacteristic] CHECK CONSTRAINT [FK_CourseLevelCharacteristics_CourseLevelCharacteristicsType_CourseLevelCharacteristicsTypeId]
GO
ALTER TABLE [edfi].[CourseOffering]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseOffering_Course_SchoolId] FOREIGN KEY([EducationOrganizationId], [CourseCode])
REFERENCES [edfi].[Course] ([EducationOrganizationId], [CourseCode])
GO
ALTER TABLE [edfi].[CourseOffering] CHECK CONSTRAINT [FK_CourseOffering_Course_SchoolId]
GO
ALTER TABLE [edfi].[CourseOffering]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseOffering_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[CourseOffering] CHECK CONSTRAINT [FK_CourseOffering_School_SchoolId]
GO
ALTER TABLE [edfi].[CourseOffering]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseOffering_Session_SchoolId] FOREIGN KEY([SchoolId], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Session] ([SchoolId], [TermTypeId], [SchoolYear])
GO
ALTER TABLE [edfi].[CourseOffering] CHECK CONSTRAINT [FK_CourseOffering_Session_SchoolId]
GO
ALTER TABLE [edfi].[CourseOfferingCurriculumUsed]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseOfferingCurriculumUsed_CourseOffering_LocalCourseCode] FOREIGN KEY([SchoolId], [TermTypeId], [SchoolYear], [LocalCourseCode])
REFERENCES [edfi].[CourseOffering] ([SchoolId], [TermTypeId], [SchoolYear], [LocalCourseCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CourseOfferingCurriculumUsed] CHECK CONSTRAINT [FK_CourseOfferingCurriculumUsed_CourseOffering_LocalCourseCode]
GO
ALTER TABLE [edfi].[CourseOfferingCurriculumUsed]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseOfferingCurriculumUsed_CurriculumUsedType_CurriculumUsedTypeId] FOREIGN KEY([CurriculumUsedTypeId])
REFERENCES [edfi].[CurriculumUsedType] ([CurriculumUsedTypeId])
GO
ALTER TABLE [edfi].[CourseOfferingCurriculumUsed] CHECK CONSTRAINT [FK_CourseOfferingCurriculumUsed_CurriculumUsedType_CurriculumUsedTypeId]
GO
ALTER TABLE [edfi].[CourseTranscript]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscript_CourseAttemptResultType_CourseAttemptResultTypeId] FOREIGN KEY([CourseAttemptResultTypeId])
REFERENCES [edfi].[CourseAttemptResultType] ([CourseAttemptResultTypeId])
GO
ALTER TABLE [edfi].[CourseTranscript] CHECK CONSTRAINT [FK_CourseTranscript_CourseAttemptResultType_CourseAttemptResultTypeId]
GO
ALTER TABLE [edfi].[CourseTranscript]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscript_CourseRepeatCodeType_CourseRepeatCodeTypeId] FOREIGN KEY([CourseRepeatCodeTypeId])
REFERENCES [edfi].[CourseRepeatCodeType] ([CourseRepeatCodeTypeId])
GO
ALTER TABLE [edfi].[CourseTranscript] CHECK CONSTRAINT [FK_CourseTranscript_CourseRepeatCodeType_CourseRepeatCodeTypeId]
GO
ALTER TABLE [edfi].[CourseTranscript]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscript_CreditType_AttemptedCreditTypeId] FOREIGN KEY([AttemptedCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[CourseTranscript] CHECK CONSTRAINT [FK_CourseTranscript_CreditType_AttemptedCreditTypeId]
GO
ALTER TABLE [edfi].[CourseTranscript]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscript_CreditType_EarnedCreditTypeId] FOREIGN KEY([EarnedCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[CourseTranscript] CHECK CONSTRAINT [FK_CourseTranscript_CreditType_EarnedCreditTypeId]
GO
ALTER TABLE [edfi].[CourseTranscript]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscript_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[CourseTranscript] CHECK CONSTRAINT [FK_CourseTranscript_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[CourseTranscript]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscript_MethodCreditEarnedType_MethodCreditEarnedTypeId] FOREIGN KEY([MethodCreditEarnedTypeId])
REFERENCES [edfi].[MethodCreditEarnedType] ([MethodCreditEarnedTypeId])
GO
ALTER TABLE [edfi].[CourseTranscript] CHECK CONSTRAINT [FK_CourseTranscript_MethodCreditEarnedType_MethodCreditEarnedTypeId]
GO
ALTER TABLE [edfi].[CourseTranscript]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscript_StudentAcademicRecord_StudentUSI] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
REFERENCES [edfi].[StudentAcademicRecord] ([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
GO
ALTER TABLE [edfi].[CourseTranscript] CHECK CONSTRAINT [FK_CourseTranscript_StudentAcademicRecord_StudentUSI]
GO
ALTER TABLE [edfi].[CourseTranscriptAdditionalCredit]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscriptAdditionalCredit_AdditionalCreditType_AdditionalCreditTypeId] FOREIGN KEY([AdditionalCreditTypeId])
REFERENCES [edfi].[AdditionalCreditType] ([AdditionalCreditTypeId])
GO
ALTER TABLE [edfi].[CourseTranscriptAdditionalCredit] CHECK CONSTRAINT [FK_CourseTranscriptAdditionalCredit_AdditionalCreditType_AdditionalCreditTypeId]
GO
ALTER TABLE [edfi].[CourseTranscriptAdditionalCredit]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscriptAdditionalCredit_CourseTranscript_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolYear], [TermTypeId], [CourseEducationOrganizationId], [EducationOrganizationId], [CourseCode], [CourseAttemptResultTypeId])
REFERENCES [edfi].[CourseTranscript] ([StudentUSI], [SchoolYear], [TermTypeId], [CourseEducationOrganizationId], [EducationOrganizationId], [CourseCode], [CourseAttemptResultTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CourseTranscriptAdditionalCredit] CHECK CONSTRAINT [FK_CourseTranscriptAdditionalCredit_CourseTranscript_StudentUSI]
GO
ALTER TABLE [edfi].[CourseTranscriptExternalCourse]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseTranscriptExternalCourse_CourseTranscript_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolYear], [TermTypeId], [CourseEducationOrganizationId], [EducationOrganizationId], [CourseCode], [CourseAttemptResultTypeId])
REFERENCES [edfi].[CourseTranscript] ([StudentUSI], [SchoolYear], [TermTypeId], [CourseEducationOrganizationId], [EducationOrganizationId], [CourseCode], [CourseAttemptResultTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CourseTranscriptExternalCourse] CHECK CONSTRAINT [FK_CourseTranscriptExternalCourse_CourseTranscript_StudentUSI]
GO
ALTER TABLE [edfi].[CredentialFieldDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_CredentialFieldDescriptor_AcademicSubjectDescriptor_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[CredentialFieldDescriptor] CHECK CONSTRAINT [FK_CredentialFieldDescriptor_AcademicSubjectDescriptor_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[CredentialFieldDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_CredentialFieldDescriptor_Descriptor_DescriptorId] FOREIGN KEY([CredentialFieldDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[CredentialFieldDescriptor] CHECK CONSTRAINT [FK_CredentialFieldDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[DiagnosisDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_DiagnosisDescriptor_Descriptor_DescriptorId] FOREIGN KEY([DiagnosisDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[DiagnosisDescriptor] CHECK CONSTRAINT [FK_DiagnosisDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[DiagnosisDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_DiagnosisDescriptor_DiagnosisType_DiagnosisTypeId] FOREIGN KEY([DiagnosisTypeId])
REFERENCES [edfi].[DiagnosisType] ([DiagnosisTypeId])
GO
ALTER TABLE [edfi].[DiagnosisDescriptor] CHECK CONSTRAINT [FK_DiagnosisDescriptor_DiagnosisType_DiagnosisTypeId]
GO
ALTER TABLE [edfi].[DisabilityDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_DisabilityDescriptor_Descriptor_DescriptorId] FOREIGN KEY([DisabilityDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[DisabilityDescriptor] CHECK CONSTRAINT [FK_DisabilityDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[DisabilityDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_DisabilityDescriptor_DisabilityCategoryType_DisabilityCategoryId] FOREIGN KEY([DisabilityCategoryTypeId])
REFERENCES [edfi].[DisabilityCategoryType] ([DisabilityCategoryTypeId])
GO
ALTER TABLE [edfi].[DisabilityDescriptor] CHECK CONSTRAINT [FK_DisabilityDescriptor_DisabilityCategoryType_DisabilityCategoryId]
GO
ALTER TABLE [edfi].[DisabilityDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_DisabilityDescriptor_DisabilityType_DisabilityTypeId] FOREIGN KEY([DisabilityTypeId])
REFERENCES [edfi].[DisabilityType] ([DisabilityTypeId])
GO
ALTER TABLE [edfi].[DisabilityDescriptor] CHECK CONSTRAINT [FK_DisabilityDescriptor_DisabilityType_DisabilityTypeId]
GO
ALTER TABLE [edfi].[DisciplineAction]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineAction_DisciplineActionLengthDifferenceReasonType_DisciplineActionLengthDifferenceReasonTypeId] FOREIGN KEY([DisciplineActionLengthDifferenceReasonTypeId])
REFERENCES [edfi].[DisciplineActionLengthDifferenceReasonType] ([DisciplineActionLengthDifferenceReasonTypeId])
GO
ALTER TABLE [edfi].[DisciplineAction] CHECK CONSTRAINT [FK_DisciplineAction_DisciplineActionLengthDifferenceReasonType_DisciplineActionLengthDifferenceReasonTypeId]
GO
ALTER TABLE [edfi].[DisciplineAction]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineAction_School_AssignmentSchoolId] FOREIGN KEY([AssignmentSchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[DisciplineAction] CHECK CONSTRAINT [FK_DisciplineAction_School_AssignmentSchoolId]
GO
ALTER TABLE [edfi].[DisciplineAction]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineAction_School_ResponsibilitySchoolId] FOREIGN KEY([ResponsibilitySchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[DisciplineAction] CHECK CONSTRAINT [FK_DisciplineAction_School_ResponsibilitySchoolId]
GO
ALTER TABLE [edfi].[DisciplineAction]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineAction_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[DisciplineAction] CHECK CONSTRAINT [FK_DisciplineAction_Student_StudentUSI]
GO
ALTER TABLE [edfi].[DisciplineActionDiscipline]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineActionDiscipline_DisciplineAction_StudentUSI] FOREIGN KEY([StudentUSI], [DisciplineActionIdentifier], [DisciplineDate])
REFERENCES [edfi].[DisciplineAction] ([StudentUSI], [DisciplineActionIdentifier], [DisciplineDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[DisciplineActionDiscipline] CHECK CONSTRAINT [FK_DisciplineActionDiscipline_DisciplineAction_StudentUSI]
GO
ALTER TABLE [edfi].[DisciplineActionDiscipline]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineActionDiscipline_DisciplineDescriptor_DisciplineDescriptorId] FOREIGN KEY([DisciplineDescriptorId])
REFERENCES [edfi].[DisciplineDescriptor] ([DisciplineDescriptorId])
GO
ALTER TABLE [edfi].[DisciplineActionDiscipline] CHECK CONSTRAINT [FK_DisciplineActionDiscipline_DisciplineDescriptor_DisciplineDescriptorId]
GO
ALTER TABLE [edfi].[DisciplineActionDisciplineIncident]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineActionDisciplineIncident_DisciplineAction_StudentUSI] FOREIGN KEY([StudentUSI], [DisciplineActionIdentifier], [DisciplineDate])
REFERENCES [edfi].[DisciplineAction] ([StudentUSI], [DisciplineActionIdentifier], [DisciplineDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[DisciplineActionDisciplineIncident] CHECK CONSTRAINT [FK_DisciplineActionDisciplineIncident_DisciplineAction_StudentUSI]
GO
ALTER TABLE [edfi].[DisciplineActionDisciplineIncident]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineActionDisciplineIncident_DisciplineIncident_SchoolId] FOREIGN KEY([SchoolId], [IncidentIdentifier])
REFERENCES [edfi].[DisciplineIncident] ([SchoolId], [IncidentIdentifier])
GO
ALTER TABLE [edfi].[DisciplineActionDisciplineIncident] CHECK CONSTRAINT [FK_DisciplineActionDisciplineIncident_DisciplineIncident_SchoolId]
GO
ALTER TABLE [edfi].[DisciplineActionStaff]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineActionStaff_DisciplineAction_StudentUSI] FOREIGN KEY([StudentUSI], [DisciplineActionIdentifier], [DisciplineDate])
REFERENCES [edfi].[DisciplineAction] ([StudentUSI], [DisciplineActionIdentifier], [DisciplineDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[DisciplineActionStaff] CHECK CONSTRAINT [FK_DisciplineActionStaff_DisciplineAction_StudentUSI]
GO
ALTER TABLE [edfi].[DisciplineActionStaff]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineActionStaff_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[DisciplineActionStaff] CHECK CONSTRAINT [FK_DisciplineActionStaff_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[DisciplineDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineDescriptor_Descriptor_DescriptorId] FOREIGN KEY([DisciplineDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[DisciplineDescriptor] CHECK CONSTRAINT [FK_DisciplineDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[DisciplineDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineDescriptor_DisciplineType_DisciplineTypeId] FOREIGN KEY([DisciplineTypeId])
REFERENCES [edfi].[DisciplineType] ([DisciplineTypeId])
GO
ALTER TABLE [edfi].[DisciplineDescriptor] CHECK CONSTRAINT [FK_DisciplineDescriptor_DisciplineType_DisciplineTypeId]
GO
ALTER TABLE [edfi].[DisciplineIncident]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineIncident_IncidentLocationType_IncidentLocationTypeId] FOREIGN KEY([IncidentLocationTypeId])
REFERENCES [edfi].[IncidentLocationType] ([IncidentLocationTypeId])
GO
ALTER TABLE [edfi].[DisciplineIncident] CHECK CONSTRAINT [FK_DisciplineIncident_IncidentLocationType_IncidentLocationTypeId]
GO
ALTER TABLE [edfi].[DisciplineIncident]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineIncident_ReporterDescriptionDescriptorId] FOREIGN KEY([ReporterDescriptionDescriptorId])
REFERENCES [edfi].[ReporterDescriptionDescriptor] ([ReporterDescriptionDescriptorId])
GO
ALTER TABLE [edfi].[DisciplineIncident] CHECK CONSTRAINT [FK_DisciplineIncident_ReporterDescriptionDescriptorId]
GO
ALTER TABLE [edfi].[DisciplineIncident]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineIncident_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[DisciplineIncident] CHECK CONSTRAINT [FK_DisciplineIncident_School_SchoolId]
GO
ALTER TABLE [edfi].[DisciplineIncident]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineIncident_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[DisciplineIncident] CHECK CONSTRAINT [FK_DisciplineIncident_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[DisciplineIncidentBehavior]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineIncidentBehavior_BehaviorDescriptor_BehaviorDescriptorId] FOREIGN KEY([BehaviorDescriptorId])
REFERENCES [edfi].[BehaviorDescriptor] ([BehaviorDescriptorId])
GO
ALTER TABLE [edfi].[DisciplineIncidentBehavior] CHECK CONSTRAINT [FK_DisciplineIncidentBehavior_BehaviorDescriptor_BehaviorDescriptorId]
GO
ALTER TABLE [edfi].[DisciplineIncidentBehavior]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineIncidentBehavior_DisciplineIncident_SchoolId] FOREIGN KEY([SchoolId], [IncidentIdentifier])
REFERENCES [edfi].[DisciplineIncident] ([SchoolId], [IncidentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[DisciplineIncidentBehavior] CHECK CONSTRAINT [FK_DisciplineIncidentBehavior_DisciplineIncident_SchoolId]
GO
ALTER TABLE [edfi].[DisciplineIncidentWeapon]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineIncidentWeapons_DisciplineIncident_SchoolId] FOREIGN KEY([SchoolId], [IncidentIdentifier])
REFERENCES [edfi].[DisciplineIncident] ([SchoolId], [IncidentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[DisciplineIncidentWeapon] CHECK CONSTRAINT [FK_DisciplineIncidentWeapons_DisciplineIncident_SchoolId]
GO
ALTER TABLE [edfi].[DisciplineIncidentWeapon]  WITH NOCHECK ADD  CONSTRAINT [FK_DisciplineIncidentWeapons_WeaponDescriptor_WeaponDescriptorId] FOREIGN KEY([WeaponDescriptorId])
REFERENCES [edfi].[WeaponDescriptor] ([WeaponDescriptorId])
GO
ALTER TABLE [edfi].[DisciplineIncidentWeapon] CHECK CONSTRAINT [FK_DisciplineIncidentWeapons_WeaponDescriptor_WeaponDescriptorId]
GO
ALTER TABLE [edfi].[EducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContent_ContentClassType_ContentClassTypeId] FOREIGN KEY([ContentClassTypeId])
REFERENCES [edfi].[ContentClassType] ([ContentClassTypeId])
GO
ALTER TABLE [edfi].[EducationContent] CHECK CONSTRAINT [FK_EducationContent_ContentClassType_ContentClassTypeId]
GO
ALTER TABLE [edfi].[EducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContent_CostRateType_CostRateTypeId] FOREIGN KEY([CostRateTypeId])
REFERENCES [edfi].[CostRateType] ([CostRateTypeId])
GO
ALTER TABLE [edfi].[EducationContent] CHECK CONSTRAINT [FK_EducationContent_CostRateType_CostRateTypeId]
GO
ALTER TABLE [edfi].[EducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContent_InteractivityStyleType_InteractivityStyleTypeId] FOREIGN KEY([InteractivityStyleTypeId])
REFERENCES [edfi].[InteractivityStyleType] ([InteractivityStyleTypeId])
GO
ALTER TABLE [edfi].[EducationContent] CHECK CONSTRAINT [FK_EducationContent_InteractivityStyleType_InteractivityStyleTypeId]
GO
ALTER TABLE [edfi].[EducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContent_LearningStandard_LearningStandardId] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
GO
ALTER TABLE [edfi].[EducationContent] CHECK CONSTRAINT [FK_EducationContent_LearningStandard_LearningStandardId]
GO
ALTER TABLE [edfi].[EducationContentAppropriateGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentAppropriateGradeLevel_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationContentAppropriateGradeLevel] CHECK CONSTRAINT [FK_EducationContentAppropriateGradeLevel_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[EducationContentAppropriateGradeLevel]  WITH CHECK ADD  CONSTRAINT [FK_EducationContentAppropriateGradeLevel_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[EducationContentAppropriateGradeLevel] CHECK CONSTRAINT [FK_EducationContentAppropriateGradeLevel_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[EducationContentAppropriateSex]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentAppropriateSex_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationContentAppropriateSex] CHECK CONSTRAINT [FK_EducationContentAppropriateSex_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[EducationContentAppropriateSex]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentAppropriateSex_SexType_SexTypeId] FOREIGN KEY([SexTypeId])
REFERENCES [edfi].[SexType] ([SexTypeId])
GO
ALTER TABLE [edfi].[EducationContentAppropriateSex] CHECK CONSTRAINT [FK_EducationContentAppropriateSex_SexType_SexTypeId]
GO
ALTER TABLE [edfi].[EducationContentAuthor]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentAuthor_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationContentAuthor] CHECK CONSTRAINT [FK_EducationContentAuthor_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceEducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentDerivativeSourceEducationContent_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceEducationContent] CHECK CONSTRAINT [FK_EducationContentDerivativeSourceEducationContent_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceEducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentDerivativeSourceEducationContent_EducationContent_DerivativeSourceContentIdentifier] FOREIGN KEY([DerivativeSourceContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceEducationContent] CHECK CONSTRAINT [FK_EducationContentDerivativeSourceEducationContent_EducationContent_DerivativeSourceContentIdentifier]
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceLearningResourceMetadataURI]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentDerivativeSourceLearningResourceMetadataURI_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceLearningResourceMetadataURI] CHECK CONSTRAINT [FK_EducationContentDerivativeSourceLearningResourceMetadataURI_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceURI]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentDerivativeSourceURI_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationContentDerivativeSourceURI] CHECK CONSTRAINT [FK_EducationContentDerivativeSourceURI_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[EducationContentLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentLanguage_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationContentLanguage] CHECK CONSTRAINT [FK_EducationContentLanguage_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[EducationContentLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationContentLanguage_LanguageDescriptor_LanguageDescriptorId] FOREIGN KEY([LanguageDescriptorId])
REFERENCES [edfi].[LanguageDescriptor] ([LanguageDescriptorId])
GO
ALTER TABLE [edfi].[EducationContentLanguage] CHECK CONSTRAINT [FK_EducationContentLanguage_LanguageDescriptor_LanguageDescriptorId]
GO
ALTER TABLE [edfi].[EducationOrganization]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganization_OperationalStatusType_OperationalStatusTypeId] FOREIGN KEY([OperationalStatusTypeId])
REFERENCES [edfi].[OperationalStatusType] ([OperationalStatusTypeId])
GO
ALTER TABLE [edfi].[EducationOrganization] CHECK CONSTRAINT [FK_EducationOrganization_OperationalStatusType_OperationalStatusTypeId]
GO
ALTER TABLE [edfi].[EducationOrganizationAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationAddress_AddressType_AddressTypeId] FOREIGN KEY([AddressTypeId])
REFERENCES [edfi].[AddressType] ([AddressTypeId])
GO
ALTER TABLE [edfi].[EducationOrganizationAddress] CHECK CONSTRAINT [FK_EducationOrganizationAddress_AddressType_AddressTypeId]
GO
ALTER TABLE [edfi].[EducationOrganizationAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationAddress_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationOrganizationAddress] CHECK CONSTRAINT [FK_EducationOrganizationAddress_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationOrganizationAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationAddress_StateAbbreviationType_StateAbbreviationTypeId] FOREIGN KEY([StateAbbreviationTypeId])
REFERENCES [edfi].[StateAbbreviationType] ([StateAbbreviationTypeId])
GO
ALTER TABLE [edfi].[EducationOrganizationAddress] CHECK CONSTRAINT [FK_EducationOrganizationAddress_StateAbbreviationType_StateAbbreviationTypeId]
GO
ALTER TABLE [edfi].[EducationOrganizationCategory]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationCategory_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationOrganizationCategory] CHECK CONSTRAINT [FK_EducationOrganizationCategory_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationOrganizationCategory]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationCategory_EducationOrganizationCategoryType_EducationOrganizationCategoryTypeId] FOREIGN KEY([EducationOrganizationCategoryTypeId])
REFERENCES [edfi].[EducationOrganizationCategoryType] ([EducationOrganizationCategoryTypeId])
GO
ALTER TABLE [edfi].[EducationOrganizationCategory] CHECK CONSTRAINT [FK_EducationOrganizationCategory_EducationOrganizationCategoryType_EducationOrganizationCategoryTypeId]
GO
ALTER TABLE [edfi].[EducationOrganizationIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationIdentificationCode_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationOrganizationIdentificationCode] CHECK CONSTRAINT [FK_EducationOrganizationIdentificationCode_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationOrganizationIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationIdentificationCode_EducationOrganizationIdentificationSystemType_EducationOrganizationIdentificationSyst] FOREIGN KEY([EducationOrganizationIdentificationSystemTypeId])
REFERENCES [edfi].[EducationOrganizationIdentificationSystemType] ([EducationOrganizationIdentificationSystemTypeId])
GO
ALTER TABLE [edfi].[EducationOrganizationIdentificationCode] CHECK CONSTRAINT [FK_EducationOrganizationIdentificationCode_EducationOrganizationIdentificationSystemType_EducationOrganizationIdentificationSyst]
GO
ALTER TABLE [edfi].[EducationOrganizationInstitutionTelephone]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationInstitutionTelephone_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationOrganizationInstitutionTelephone] CHECK CONSTRAINT [FK_EducationOrganizationInstitutionTelephone_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationOrganizationInstitutionTelephone]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationInstitutionTelephone_InstitutionTelephoneNumberType_InstitutionTelephoneNumberTypeId] FOREIGN KEY([InstitutionTelephoneNumberTypeId])
REFERENCES [edfi].[InstitutionTelephoneNumberType] ([InstitutionTelephoneNumberTypeId])
GO
ALTER TABLE [edfi].[EducationOrganizationInstitutionTelephone] CHECK CONSTRAINT [FK_EducationOrganizationInstitutionTelephone_InstitutionTelephoneNumberType_InstitutionTelephoneNumberTypeId]
GO
ALTER TABLE [edfi].[EducationOrganizationInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationInternationalAddress_AddressType_AddressTypeId] FOREIGN KEY([AddressTypeId])
REFERENCES [edfi].[AddressType] ([AddressTypeId])
GO
ALTER TABLE [edfi].[EducationOrganizationInternationalAddress] CHECK CONSTRAINT [FK_EducationOrganizationInternationalAddress_AddressType_AddressTypeId]
GO
ALTER TABLE [edfi].[EducationOrganizationInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationInternationalAddress_CountryType_CountryTypeId] FOREIGN KEY([CountryTypeId])
REFERENCES [edfi].[CountryType] ([CountryTypeId])
GO
ALTER TABLE [edfi].[EducationOrganizationInternationalAddress] CHECK CONSTRAINT [FK_EducationOrganizationInternationalAddress_CountryType_CountryTypeId]
GO
ALTER TABLE [edfi].[EducationOrganizationInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationInternationalAddress_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationOrganizationInternationalAddress] CHECK CONSTRAINT [FK_EducationOrganizationInternationalAddress_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationOrganizationInterventionPrescriptionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationInterventionPrescriptionAssociation_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[EducationOrganizationInterventionPrescriptionAssociation] CHECK CONSTRAINT [FK_EducationOrganizationInterventionPrescriptionAssociation_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationOrganizationInterventionPrescriptionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationInterventionPrescriptionAssociation_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [InterventionPrescriptionEducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
GO
ALTER TABLE [edfi].[EducationOrganizationInterventionPrescriptionAssociation] CHECK CONSTRAINT [FK_EducationOrganizationInterventionPrescriptionAssociation_InterventionPrescription]
GO
ALTER TABLE [edfi].[EducationOrganizationNetwork]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationNetwork_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationNetworkId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationOrganizationNetwork] CHECK CONSTRAINT [FK_EducationOrganizationNetwork_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationOrganizationNetwork]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationNetwork_NetworkPurposeType_NetworkPurposeTypeId] FOREIGN KEY([NetworkPurposeTypeId])
REFERENCES [edfi].[NetworkPurposeType] ([NetworkPurposeTypeId])
GO
ALTER TABLE [edfi].[EducationOrganizationNetwork] CHECK CONSTRAINT [FK_EducationOrganizationNetwork_NetworkPurposeType_NetworkPurposeTypeId]
GO
ALTER TABLE [edfi].[EducationOrganizationNetworkAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationNetworkAssociation_EducationOrganization_EducationOrganizationId] FOREIGN KEY([MemberEducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[EducationOrganizationNetworkAssociation] CHECK CONSTRAINT [FK_EducationOrganizationNetworkAssociation_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationOrganizationNetworkAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationNetworkAssociation_EducationOrganizationNetwork_EducationOrganizationNetworkId] FOREIGN KEY([EducationOrganizationNetworkId])
REFERENCES [edfi].[EducationOrganizationNetwork] ([EducationOrganizationNetworkId])
GO
ALTER TABLE [edfi].[EducationOrganizationNetworkAssociation] CHECK CONSTRAINT [FK_EducationOrganizationNetworkAssociation_EducationOrganizationNetwork_EducationOrganizationNetworkId]
GO
ALTER TABLE [edfi].[EducationOrganizationPeerAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationPeerAssociation_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[EducationOrganizationPeerAssociation] CHECK CONSTRAINT [FK_EducationOrganizationPeerAssociation_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationOrganizationPeerAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationOrganizationPeerAssociation_EducationOrganization_PeerEducationOrganizationId] FOREIGN KEY([PeerEducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[EducationOrganizationPeerAssociation] CHECK CONSTRAINT [FK_EducationOrganizationPeerAssociation_EducationOrganization_PeerEducationOrganizationId]
GO
ALTER TABLE [edfi].[EducationServiceCenter]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationServiceCenter_EducationOrganization_EducationServiceCenterId] FOREIGN KEY([EducationServiceCenterId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EducationServiceCenter] CHECK CONSTRAINT [FK_EducationServiceCenter_EducationOrganization_EducationServiceCenterId]
GO
ALTER TABLE [edfi].[EducationServiceCenter]  WITH NOCHECK ADD  CONSTRAINT [FK_EducationServiceCenter_StateEducationAgency_StateEducationAgencyId] FOREIGN KEY([StateEducationAgencyId])
REFERENCES [edfi].[StateEducationAgency] ([StateEducationAgencyId])
GO
ALTER TABLE [edfi].[EducationServiceCenter] CHECK CONSTRAINT [FK_EducationServiceCenter_StateEducationAgency_StateEducationAgencyId]
GO
ALTER TABLE [edfi].[EmploymentStatusDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_EmploymentStatusDescriptor_Descriptor_DescriptorId] FOREIGN KEY([EmploymentStatusDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EmploymentStatusDescriptor] CHECK CONSTRAINT [FK_EmploymentStatusDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[EmploymentStatusDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_EmploymentStatusDescriptor_EmploymentStatusType_EmploymentStatusTypeId] FOREIGN KEY([EmploymentStatusTypeId])
REFERENCES [edfi].[EmploymentStatusType] ([EmploymentStatusTypeId])
GO
ALTER TABLE [edfi].[EmploymentStatusDescriptor] CHECK CONSTRAINT [FK_EmploymentStatusDescriptor_EmploymentStatusType_EmploymentStatusTypeId]
GO
ALTER TABLE [edfi].[EntryTypeDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_EntryTypeDescriptor_Descriptor_DescriptorId] FOREIGN KEY([EntryTypeDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[EntryTypeDescriptor] CHECK CONSTRAINT [FK_EntryTypeDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[EntryTypeDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_EntryTypeDescriptor_EntryType_EntryTypeId] FOREIGN KEY([EntryTypeId])
REFERENCES [edfi].[EntryType] ([EntryTypeId])
GO
ALTER TABLE [edfi].[EntryTypeDescriptor] CHECK CONSTRAINT [FK_EntryTypeDescriptor_EntryType_EntryTypeId]
GO
ALTER TABLE [edfi].[ExitWithdrawTypeDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ExitWithdrawTypeDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ExitWithdrawTypeDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ExitWithdrawTypeDescriptor] CHECK CONSTRAINT [FK_ExitWithdrawTypeDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[ExitWithdrawTypeDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ExitWithdrawTypeDescriptor_ExitWithdrawType_ExitWithdrawTypeId] FOREIGN KEY([ExitWithdrawTypeId])
REFERENCES [edfi].[ExitWithdrawType] ([ExitWithdrawTypeId])
GO
ALTER TABLE [edfi].[ExitWithdrawTypeDescriptor] CHECK CONSTRAINT [FK_ExitWithdrawTypeDescriptor_ExitWithdrawType_ExitWithdrawTypeId]
GO
ALTER TABLE [edfi].[FeederSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_FeederSchoolAssociation_School_FeederSchoolId] FOREIGN KEY([FeederSchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[FeederSchoolAssociation] CHECK CONSTRAINT [FK_FeederSchoolAssociation_School_FeederSchoolId]
GO
ALTER TABLE [edfi].[FeederSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_FeederSchoolAssociation_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[FeederSchoolAssociation] CHECK CONSTRAINT [FK_FeederSchoolAssociation_School_SchoolId]
GO
ALTER TABLE [edfi].[Grade]  WITH NOCHECK ADD  CONSTRAINT [FK_Grade_GradeType_GradeTypeId] FOREIGN KEY([GradeTypeId])
REFERENCES [edfi].[GradeType] ([GradeTypeId])
GO
ALTER TABLE [edfi].[Grade] CHECK CONSTRAINT [FK_Grade_GradeType_GradeTypeId]
GO
ALTER TABLE [edfi].[Grade]  WITH NOCHECK ADD  CONSTRAINT [FK_Grade_GradingPeriod] FOREIGN KEY([GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
REFERENCES [edfi].[GradingPeriod] ([EducationOrganizationId], [GradingPeriodDescriptorId], [BeginDate])
GO
ALTER TABLE [edfi].[Grade] CHECK CONSTRAINT [FK_Grade_GradingPeriod]
GO
ALTER TABLE [edfi].[Grade]  WITH NOCHECK ADD  CONSTRAINT [FK_Grade_PerformanceBaseType_PerformanceBaseConversionTypeId] FOREIGN KEY([PerformanceBaseConversionTypeId])
REFERENCES [edfi].[PerformanceBaseConversionType] ([PerformanceBaseConversionTypeId])
GO
ALTER TABLE [edfi].[Grade] CHECK CONSTRAINT [FK_Grade_PerformanceBaseType_PerformanceBaseConversionTypeId]
GO
ALTER TABLE [edfi].[Grade]  WITH NOCHECK ADD  CONSTRAINT [FK_Grade_StudentSectionAssociation] FOREIGN KEY([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate])
REFERENCES [edfi].[StudentSectionAssociation] ([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[Grade] CHECK CONSTRAINT [FK_Grade_StudentSectionAssociation]
GO
ALTER TABLE [edfi].[GradebookEntry]  WITH NOCHECK ADD  CONSTRAINT [FK_GradebookEntry_GradebookEntryType_GradebookEntryTypeId] FOREIGN KEY([GradebookEntryTypeId])
REFERENCES [edfi].[GradebookEntryType] ([GradebookEntryTypeId])
GO
ALTER TABLE [edfi].[GradebookEntry] CHECK CONSTRAINT [FK_GradebookEntry_GradebookEntryType_GradebookEntryTypeId]
GO
ALTER TABLE [edfi].[GradebookEntry]  WITH NOCHECK ADD  CONSTRAINT [FK_GradebookEntry_GradingPeriod] FOREIGN KEY([EducationOrganizationId], [GradingPeriodDescriptorId], [BeginDate])
REFERENCES [edfi].[GradingPeriod] ([EducationOrganizationId], [GradingPeriodDescriptorId], [BeginDate])
GO
ALTER TABLE [edfi].[GradebookEntry] CHECK CONSTRAINT [FK_GradebookEntry_GradingPeriod]
GO
ALTER TABLE [edfi].[GradebookEntry]  WITH NOCHECK ADD  CONSTRAINT [FK_GradebookEntry_Section_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Section] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[GradebookEntry] CHECK CONSTRAINT [FK_GradebookEntry_Section_SchoolId]
GO
ALTER TABLE [edfi].[GradebookEntryLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_GradebookEntryLearningObjective_GradebookEntry_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [GradebookEntryTitle], [DateAssigned])
REFERENCES [edfi].[GradebookEntry] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [GradebookEntryTitle], [DateAssigned])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[GradebookEntryLearningObjective] CHECK CONSTRAINT [FK_GradebookEntryLearningObjective_GradebookEntry_SchoolId]
GO
ALTER TABLE [edfi].[GradebookEntryLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_GradebookEntryLearningObjective_LearningObjective_Objective] FOREIGN KEY([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[LearningObjective] ([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[GradebookEntryLearningObjective] CHECK CONSTRAINT [FK_GradebookEntryLearningObjective_LearningObjective_Objective]
GO
ALTER TABLE [edfi].[GradebookEntryLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_GradebookEntryLearningStandard_GradebookEntry_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [GradebookEntryTitle], [DateAssigned])
REFERENCES [edfi].[GradebookEntry] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [GradebookEntryTitle], [DateAssigned])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[GradebookEntryLearningStandard] CHECK CONSTRAINT [FK_GradebookEntryLearningStandard_GradebookEntry_SchoolId]
GO
ALTER TABLE [edfi].[GradebookEntryLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_GradebookEntryLearningStandard_LearningStandard_LearningStandardId] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
GO
ALTER TABLE [edfi].[GradebookEntryLearningStandard] CHECK CONSTRAINT [FK_GradebookEntryLearningStandard_LearningStandard_LearningStandardId]
GO
ALTER TABLE [edfi].[GradeLevelDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_GradeLevelDescriptor_Descriptor_DescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[GradeLevelDescriptor] CHECK CONSTRAINT [FK_GradeLevelDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[GradeLevelDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_GradeLevelDescriptor_GradeLevelType_GradeLevelTypeId] FOREIGN KEY([GradeLevelTypeId])
REFERENCES [edfi].[GradeLevelType] ([GradeLevelTypeId])
GO
ALTER TABLE [edfi].[GradeLevelDescriptor] CHECK CONSTRAINT [FK_GradeLevelDescriptor_GradeLevelType_GradeLevelTypeId]
GO
ALTER TABLE [edfi].[GradingPeriod]  WITH NOCHECK ADD  CONSTRAINT [FK_GradingPeriod_CalendarDate_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [BeginDate])
REFERENCES [edfi].[CalendarDate] ([EducationOrganizationId], [Date])
GO
ALTER TABLE [edfi].[GradingPeriod] CHECK CONSTRAINT [FK_GradingPeriod_CalendarDate_EducationOrganizationId]
GO
ALTER TABLE [edfi].[GradingPeriod]  WITH NOCHECK ADD  CONSTRAINT [FK_GradingPeriod_CalendarDate_EndDate] FOREIGN KEY([EducationOrganizationId], [EndDate])
REFERENCES [edfi].[CalendarDate] ([EducationOrganizationId], [Date])
GO
ALTER TABLE [edfi].[GradingPeriod] CHECK CONSTRAINT [FK_GradingPeriod_CalendarDate_EndDate]
GO
ALTER TABLE [edfi].[GradingPeriod]  WITH NOCHECK ADD  CONSTRAINT [FK_GradingPeriod_GradingPeriodDescriptorId] FOREIGN KEY([GradingPeriodDescriptorId])
REFERENCES [edfi].[GradingPeriodDescriptor] ([GradingPeriodDescriptorId])
GO
ALTER TABLE [edfi].[GradingPeriod] CHECK CONSTRAINT [FK_GradingPeriod_GradingPeriodDescriptorId]
GO
ALTER TABLE [edfi].[GradingPeriodDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_GradingPeriodDescriptor_Descriptor_DescriptorId] FOREIGN KEY([GradingPeriodDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[GradingPeriodDescriptor] CHECK CONSTRAINT [FK_GradingPeriodDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[GradingPeriodDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_GradingPeriodDescriptor_GradingPeriodType_GradingPeriodTypeId] FOREIGN KEY([GradingPeriodTypeId])
REFERENCES [edfi].[GradingPeriodType] ([GradingPeriodTypeId])
GO
ALTER TABLE [edfi].[GradingPeriodDescriptor] CHECK CONSTRAINT [FK_GradingPeriodDescriptor_GradingPeriodType_GradingPeriodTypeId]
GO
ALTER TABLE [edfi].[GraduationPlan]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlan_CreditType_TotalCreditsRequiredCreditTypeId] FOREIGN KEY([TotalRequiredCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[GraduationPlan] CHECK CONSTRAINT [FK_GraduationPlan_CreditType_TotalCreditsRequiredCreditTypeId]
GO
ALTER TABLE [edfi].[GraduationPlan]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlan_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[GraduationPlan] CHECK CONSTRAINT [FK_GraduationPlan_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[GraduationPlan]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlan_GraduationPlanTypeDescriptor_GraduationPlanTypeDescriptorId] FOREIGN KEY([GraduationPlanTypeDescriptorId])
REFERENCES [edfi].[GraduationPlanTypeDescriptor] ([GraduationPlanTypeDescriptorId])
GO
ALTER TABLE [edfi].[GraduationPlan] CHECK CONSTRAINT [FK_GraduationPlan_GraduationPlanTypeDescriptor_GraduationPlanTypeDescriptorId]
GO
ALTER TABLE [edfi].[GraduationPlan]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlan_SchoolYearType_GraduationSchoolYear] FOREIGN KEY([GraduationSchoolYear])
REFERENCES [edfi].[SchoolYearType] ([SchoolYear])
GO
ALTER TABLE [edfi].[GraduationPlan] CHECK CONSTRAINT [FK_GraduationPlan_SchoolYearType_GraduationSchoolYear]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourse]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlanCreditsByCourse_CreditType_CreditTypeId] FOREIGN KEY([CreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourse] CHECK CONSTRAINT [FK_GraduationPlanCreditsByCourse_CreditType_CreditTypeId]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourse]  WITH CHECK ADD  CONSTRAINT [FK_GraduationPlanCreditsByCourse_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourse] CHECK CONSTRAINT [FK_GraduationPlanCreditsByCourse_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourse]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlanCreditsByCourse_GraduationPlan_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [GraduationPlanTypeDescriptorId], [GraduationSchoolYear])
REFERENCES [edfi].[GraduationPlan] ([EducationOrganizationId], [GraduationPlanTypeDescriptorId], [GraduationSchoolYear])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourse] CHECK CONSTRAINT [FK_GraduationPlanCreditsByCourse_GraduationPlan_EducationOrganizationId]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourseCourse]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlanCreditsByCourseCourse_Course] FOREIGN KEY([CourseEducationOrganizationId], [CourseCode])
REFERENCES [edfi].[Course] ([EducationOrganizationId], [CourseCode])
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourseCourse] CHECK CONSTRAINT [FK_GraduationPlanCreditsByCourseCourse_Course]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourseCourse]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlanCreditsByCourseCourse_GraduationPlanCreditsByCourse] FOREIGN KEY([EducationOrganizationId], [GraduationPlanTypeDescriptorId], [GraduationSchoolYear], [CourseSetName])
REFERENCES [edfi].[GraduationPlanCreditsByCourse] ([EducationOrganizationId], [GraduationPlanTypeDescriptorId], [GraduationSchoolYear], [CourseSetName])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[GraduationPlanCreditsByCourseCourse] CHECK CONSTRAINT [FK_GraduationPlanCreditsByCourseCourse_GraduationPlanCreditsByCourse]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsBySubject]  WITH CHECK ADD  CONSTRAINT [FK_GraduationPlanCreditsBySubject_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[GraduationPlanCreditsBySubject] CHECK CONSTRAINT [FK_GraduationPlanCreditsBySubject_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsBySubject]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlanCreditsBySubject_CreditType_CreditTypeId] FOREIGN KEY([CreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[GraduationPlanCreditsBySubject] CHECK CONSTRAINT [FK_GraduationPlanCreditsBySubject_CreditType_CreditTypeId]
GO
ALTER TABLE [edfi].[GraduationPlanCreditsBySubject]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlanCreditsBySubject_GraduationPlan_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [GraduationPlanTypeDescriptorId], [GraduationSchoolYear])
REFERENCES [edfi].[GraduationPlan] ([EducationOrganizationId], [GraduationPlanTypeDescriptorId], [GraduationSchoolYear])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[GraduationPlanCreditsBySubject] CHECK CONSTRAINT [FK_GraduationPlanCreditsBySubject_GraduationPlan_EducationOrganizationId]
GO
ALTER TABLE [edfi].[GraduationPlanTypeDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlanTypeDescriptor_Descriptor_DescriptorId] FOREIGN KEY([GraduationPlanTypeDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[GraduationPlanTypeDescriptor] CHECK CONSTRAINT [FK_GraduationPlanTypeDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[GraduationPlanTypeDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_GraduationPlanTypeDescriptor_GraduationPlanType_GraduationPlanTypeId] FOREIGN KEY([GraduationPlanTypeId])
REFERENCES [edfi].[GraduationPlanType] ([GraduationPlanTypeId])
GO
ALTER TABLE [edfi].[GraduationPlanTypeDescriptor] CHECK CONSTRAINT [FK_GraduationPlanTypeDescriptor_GraduationPlanType_GraduationPlanTypeId]
GO
ALTER TABLE [edfi].[Intervention]  WITH NOCHECK ADD  CONSTRAINT [FK_Intervention_DeliveryMethodType_DeliveryMethodTypeId] FOREIGN KEY([DeliveryMethodTypeId])
REFERENCES [edfi].[DeliveryMethodType] ([DeliveryMethodTypeId])
GO
ALTER TABLE [edfi].[Intervention] CHECK CONSTRAINT [FK_Intervention_DeliveryMethodType_DeliveryMethodTypeId]
GO
ALTER TABLE [edfi].[Intervention]  WITH NOCHECK ADD  CONSTRAINT [FK_Intervention_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[Intervention] CHECK CONSTRAINT [FK_Intervention_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[Intervention]  WITH NOCHECK ADD  CONSTRAINT [FK_Intervention_InterventionClassType_InterventionClassTypeId] FOREIGN KEY([InterventionClassTypeId])
REFERENCES [edfi].[InterventionClassType] ([InterventionClassTypeId])
GO
ALTER TABLE [edfi].[Intervention] CHECK CONSTRAINT [FK_Intervention_InterventionClassType_InterventionClassTypeId]
GO
ALTER TABLE [edfi].[InterventionAppropriateGradeLevel]  WITH CHECK ADD  CONSTRAINT [FK_InterventionAppropriateGradeLevel_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[InterventionAppropriateGradeLevel] CHECK CONSTRAINT [FK_InterventionAppropriateGradeLevel_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[InterventionAppropriateGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionAppropriateGradeLevel_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionAppropriateGradeLevel] CHECK CONSTRAINT [FK_InterventionAppropriateGradeLevel_Intervention]
GO
ALTER TABLE [edfi].[InterventionAppropriateSex]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionAppropriateSex_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionAppropriateSex] CHECK CONSTRAINT [FK_InterventionAppropriateSex_Intervention]
GO
ALTER TABLE [edfi].[InterventionAppropriateSex]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionAppropriateSex_SexType_SexTypeId] FOREIGN KEY([SexTypeId])
REFERENCES [edfi].[SexType] ([SexTypeId])
GO
ALTER TABLE [edfi].[InterventionAppropriateSex] CHECK CONSTRAINT [FK_InterventionAppropriateSex_SexType_SexTypeId]
GO
ALTER TABLE [edfi].[InterventionDiagnosis]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionDiagnosis_DiagnosisDescriptor_DiagnosisDescriptorId] FOREIGN KEY([DiagnosisDescriptorId])
REFERENCES [edfi].[DiagnosisDescriptor] ([DiagnosisDescriptorId])
GO
ALTER TABLE [edfi].[InterventionDiagnosis] CHECK CONSTRAINT [FK_InterventionDiagnosis_DiagnosisDescriptor_DiagnosisDescriptorId]
GO
ALTER TABLE [edfi].[InterventionDiagnosis]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionDiagnosis_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionDiagnosis] CHECK CONSTRAINT [FK_InterventionDiagnosis_Intervention]
GO
ALTER TABLE [edfi].[InterventionEducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionEducationContent_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
GO
ALTER TABLE [edfi].[InterventionEducationContent] CHECK CONSTRAINT [FK_InterventionEducationContent_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[InterventionEducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionEducationContent_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionEducationContent] CHECK CONSTRAINT [FK_InterventionEducationContent_Intervention]
GO
ALTER TABLE [edfi].[InterventionInterventionPrescription]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionInterventionPrescription_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionInterventionPrescription] CHECK CONSTRAINT [FK_InterventionInterventionPrescription_Intervention]
GO
ALTER TABLE [edfi].[InterventionInterventionPrescription]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionInterventionPrescription_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [InterventionPrescriptionEducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
GO
ALTER TABLE [edfi].[InterventionInterventionPrescription] CHECK CONSTRAINT [FK_InterventionInterventionPrescription_InterventionPrescription]
GO
ALTER TABLE [edfi].[InterventionLearningResourceMetadataURI]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionLearningResourceMetadataURI_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionLearningResourceMetadataURI] CHECK CONSTRAINT [FK_InterventionLearningResourceMetadataURI_Intervention]
GO
ALTER TABLE [edfi].[InterventionMeetingTime]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionMeetingTime_ClassPeriod_ClassPeriodName] FOREIGN KEY([SchoolId], [ClassPeriodName])
REFERENCES [edfi].[ClassPeriod] ([SchoolId], [ClassPeriodName])
GO
ALTER TABLE [edfi].[InterventionMeetingTime] CHECK CONSTRAINT [FK_InterventionMeetingTime_ClassPeriod_ClassPeriodName]
GO
ALTER TABLE [edfi].[InterventionMeetingTime]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionMeetingTime_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionMeetingTime] CHECK CONSTRAINT [FK_InterventionMeetingTime_Intervention]
GO
ALTER TABLE [edfi].[InterventionPopulationServed]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPopulationServed_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionPopulationServed] CHECK CONSTRAINT [FK_InterventionPopulationServed_Intervention]
GO
ALTER TABLE [edfi].[InterventionPopulationServed]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPopulationServed_PopulationServedType_PopulationServedTypeId] FOREIGN KEY([PopulationServedTypeId])
REFERENCES [edfi].[PopulationServedType] ([PopulationServedTypeId])
GO
ALTER TABLE [edfi].[InterventionPopulationServed] CHECK CONSTRAINT [FK_InterventionPopulationServed_PopulationServedType_PopulationServedTypeId]
GO
ALTER TABLE [edfi].[InterventionPrescription]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescription_DeliveryMethodType_DeliveryMethodTypeId] FOREIGN KEY([DeliveryMethodTypeId])
REFERENCES [edfi].[DeliveryMethodType] ([DeliveryMethodTypeId])
GO
ALTER TABLE [edfi].[InterventionPrescription] CHECK CONSTRAINT [FK_InterventionPrescription_DeliveryMethodType_DeliveryMethodTypeId]
GO
ALTER TABLE [edfi].[InterventionPrescription]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescription_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[InterventionPrescription] CHECK CONSTRAINT [FK_InterventionPrescription_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[InterventionPrescription]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescription_InterventionClassType_InterventionClassTypeId] FOREIGN KEY([InterventionClassTypeId])
REFERENCES [edfi].[InterventionClassType] ([InterventionClassTypeId])
GO
ALTER TABLE [edfi].[InterventionPrescription] CHECK CONSTRAINT [FK_InterventionPrescription_InterventionClassType_InterventionClassTypeId]
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateGradeLevel]  WITH CHECK ADD  CONSTRAINT [FK_InterventionPrescriptionAppropriateGradeLevel_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateGradeLevel] CHECK CONSTRAINT [FK_InterventionPrescriptionAppropriateGradeLevel_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionAppropriateGradeLevel_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateGradeLevel] CHECK CONSTRAINT [FK_InterventionPrescriptionAppropriateGradeLevel_InterventionPrescription]
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateSex]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionAppropriateSex_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateSex] CHECK CONSTRAINT [FK_InterventionPrescriptionAppropriateSex_InterventionPrescription]
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateSex]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionAppropriateSex_SexType_SexTypeId] FOREIGN KEY([SexTypeId])
REFERENCES [edfi].[SexType] ([SexTypeId])
GO
ALTER TABLE [edfi].[InterventionPrescriptionAppropriateSex] CHECK CONSTRAINT [FK_InterventionPrescriptionAppropriateSex_SexType_SexTypeId]
GO
ALTER TABLE [edfi].[InterventionPrescriptionDiagnosis]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionDiagnosis_DiagnosisDescriptor_DiagnosisDescriptorId] FOREIGN KEY([DiagnosisDescriptorId])
REFERENCES [edfi].[DiagnosisDescriptor] ([DiagnosisDescriptorId])
GO
ALTER TABLE [edfi].[InterventionPrescriptionDiagnosis] CHECK CONSTRAINT [FK_InterventionPrescriptionDiagnosis_DiagnosisDescriptor_DiagnosisDescriptorId]
GO
ALTER TABLE [edfi].[InterventionPrescriptionDiagnosis]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionDiagnosis_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionPrescriptionDiagnosis] CHECK CONSTRAINT [FK_InterventionPrescriptionDiagnosis_InterventionPrescription]
GO
ALTER TABLE [edfi].[InterventionPrescriptionEducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionEducationContent_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
GO
ALTER TABLE [edfi].[InterventionPrescriptionEducationContent] CHECK CONSTRAINT [FK_InterventionPrescriptionEducationContent_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[InterventionPrescriptionEducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionEducationContent_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionPrescriptionEducationContent] CHECK CONSTRAINT [FK_InterventionPrescriptionEducationContent_InterventionPrescription]
GO
ALTER TABLE [edfi].[InterventionPrescriptionLearningResourceMetadataURI]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionLearningResourceMetadataURI_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionPrescriptionLearningResourceMetadataURI] CHECK CONSTRAINT [FK_InterventionPrescriptionLearningResourceMetadataURI_InterventionPrescription]
GO
ALTER TABLE [edfi].[InterventionPrescriptionPopulationServed]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionPopulationServed_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionPrescriptionPopulationServed] CHECK CONSTRAINT [FK_InterventionPrescriptionPopulationServed_InterventionPrescription]
GO
ALTER TABLE [edfi].[InterventionPrescriptionPopulationServed]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionPopulationServed_PopulationServedType_PopulationServedTypeId] FOREIGN KEY([PopulationServedTypeId])
REFERENCES [edfi].[PopulationServedType] ([PopulationServedTypeId])
GO
ALTER TABLE [edfi].[InterventionPrescriptionPopulationServed] CHECK CONSTRAINT [FK_InterventionPrescriptionPopulationServed_PopulationServedType_PopulationServedTypeId]
GO
ALTER TABLE [edfi].[InterventionPrescriptionURI]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionPrescriptionURI_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionPrescriptionURI] CHECK CONSTRAINT [FK_InterventionPrescriptionURI_InterventionPrescription]
GO
ALTER TABLE [edfi].[InterventionStaff]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStaff_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionStaff] CHECK CONSTRAINT [FK_InterventionStaff_Intervention]
GO
ALTER TABLE [edfi].[InterventionStaff]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStaff_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[InterventionStaff] CHECK CONSTRAINT [FK_InterventionStaff_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[InterventionStudy]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudy_DeliveryMethodType_DeliveryMethodTypeId] FOREIGN KEY([DeliveryMethodTypeId])
REFERENCES [edfi].[DeliveryMethodType] ([DeliveryMethodTypeId])
GO
ALTER TABLE [edfi].[InterventionStudy] CHECK CONSTRAINT [FK_InterventionStudy_DeliveryMethodType_DeliveryMethodTypeId]
GO
ALTER TABLE [edfi].[InterventionStudy]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudy_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[InterventionStudy] CHECK CONSTRAINT [FK_InterventionStudy_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[InterventionStudy]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudy_InterventionClassType_InterventionClassTypeId] FOREIGN KEY([InterventionClassTypeId])
REFERENCES [edfi].[InterventionClassType] ([InterventionClassTypeId])
GO
ALTER TABLE [edfi].[InterventionStudy] CHECK CONSTRAINT [FK_InterventionStudy_InterventionClassType_InterventionClassTypeId]
GO
ALTER TABLE [edfi].[InterventionStudy]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudy_InterventionPrescription] FOREIGN KEY([InterventionPrescriptionIdentificationCode], [InterventionPrescriptionEducationOrganizationId])
REFERENCES [edfi].[InterventionPrescription] ([InterventionPrescriptionIdentificationCode], [EducationOrganizationId])
GO
ALTER TABLE [edfi].[InterventionStudy] CHECK CONSTRAINT [FK_InterventionStudy_InterventionPrescription]
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateGradeLevel]  WITH CHECK ADD  CONSTRAINT [FK_InterventionStudyAppropriateGradeLevel_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateGradeLevel] CHECK CONSTRAINT [FK_InterventionStudyAppropriateGradeLevel_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyAppropriateGradeLevel_InterventionStudy] FOREIGN KEY([InterventionStudyIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionStudy] ([InterventionStudyIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateGradeLevel] CHECK CONSTRAINT [FK_InterventionStudyAppropriateGradeLevel_InterventionStudy]
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateSex]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyAppropriateSex_InterventionStudy] FOREIGN KEY([InterventionStudyIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionStudy] ([InterventionStudyIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateSex] CHECK CONSTRAINT [FK_InterventionStudyAppropriateSex_InterventionStudy]
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateSex]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyAppropriateSex_SexType_SexTypeId] FOREIGN KEY([SexTypeId])
REFERENCES [edfi].[SexType] ([SexTypeId])
GO
ALTER TABLE [edfi].[InterventionStudyAppropriateSex] CHECK CONSTRAINT [FK_InterventionStudyAppropriateSex_SexType_SexTypeId]
GO
ALTER TABLE [edfi].[InterventionStudyEducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyEducationContent_EducationContent_ContentIdentifier] FOREIGN KEY([ContentIdentifier])
REFERENCES [edfi].[EducationContent] ([ContentIdentifier])
GO
ALTER TABLE [edfi].[InterventionStudyEducationContent] CHECK CONSTRAINT [FK_InterventionStudyEducationContent_EducationContent_ContentIdentifier]
GO
ALTER TABLE [edfi].[InterventionStudyEducationContent]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyEducationContent_InterventionStudy] FOREIGN KEY([InterventionStudyIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionStudy] ([InterventionStudyIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionStudyEducationContent] CHECK CONSTRAINT [FK_InterventionStudyEducationContent_InterventionStudy]
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_DiagnosisDescriptor_DiagnosisDescriptorId] FOREIGN KEY([DiagnosisDescriptorId])
REFERENCES [edfi].[DiagnosisDescriptor] ([DiagnosisDescriptorId])
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness] CHECK CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_DiagnosisDescriptor_DiagnosisDescriptorId]
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness]  WITH CHECK ADD  CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness] CHECK CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_InterventionEffectivenessRatingType_InterventionEffectivenessRatingTypeId] FOREIGN KEY([InterventionEffectivenessRatingTypeId])
REFERENCES [edfi].[InterventionEffectivenessRatingType] ([InterventionEffectivenessRatingTypeId])
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness] CHECK CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_InterventionEffectivenessRatingType_InterventionEffectivenessRatingTypeId]
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_InterventionStudy] FOREIGN KEY([InterventionStudyIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionStudy] ([InterventionStudyIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness] CHECK CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_InterventionStudy]
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_PopulationServedType_PopulationServedTypeId] FOREIGN KEY([PopulationServedTypeId])
REFERENCES [edfi].[PopulationServedType] ([PopulationServedTypeId])
GO
ALTER TABLE [edfi].[InterventionStudyInterventionEffectiveness] CHECK CONSTRAINT [FK_InterventionStudyInterventionEffectiveness_PopulationServedType_PopulationServedTypeId]
GO
ALTER TABLE [edfi].[InterventionStudyLearningResourceMetadataURI]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyLearningResourceMetadataURI_InterventionStudy] FOREIGN KEY([InterventionStudyIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionStudy] ([InterventionStudyIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionStudyLearningResourceMetadataURI] CHECK CONSTRAINT [FK_InterventionStudyLearningResourceMetadataURI_InterventionStudy]
GO
ALTER TABLE [edfi].[InterventionStudyPopulationServed]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyPopulationServed_InterventionStudy] FOREIGN KEY([InterventionStudyIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionStudy] ([InterventionStudyIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionStudyPopulationServed] CHECK CONSTRAINT [FK_InterventionStudyPopulationServed_InterventionStudy]
GO
ALTER TABLE [edfi].[InterventionStudyPopulationServed]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyPopulationServed_PopulationServedType_PopulationServedTypeId] FOREIGN KEY([PopulationServedTypeId])
REFERENCES [edfi].[PopulationServedType] ([PopulationServedTypeId])
GO
ALTER TABLE [edfi].[InterventionStudyPopulationServed] CHECK CONSTRAINT [FK_InterventionStudyPopulationServed_PopulationServedType_PopulationServedTypeId]
GO
ALTER TABLE [edfi].[InterventionStudyStateAbbreviation]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyStateAbbreviation_InterventionStudy] FOREIGN KEY([InterventionStudyIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionStudy] ([InterventionStudyIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionStudyStateAbbreviation] CHECK CONSTRAINT [FK_InterventionStudyStateAbbreviation_InterventionStudy]
GO
ALTER TABLE [edfi].[InterventionStudyStateAbbreviation]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyStateAbbreviation_StateAbbreviationType_StateAbbreviationTypeId] FOREIGN KEY([StateAbbreviationTypeId])
REFERENCES [edfi].[StateAbbreviationType] ([StateAbbreviationTypeId])
GO
ALTER TABLE [edfi].[InterventionStudyStateAbbreviation] CHECK CONSTRAINT [FK_InterventionStudyStateAbbreviation_StateAbbreviationType_StateAbbreviationTypeId]
GO
ALTER TABLE [edfi].[InterventionStudyURI]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionStudyURI_InterventionStudy] FOREIGN KEY([InterventionStudyIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[InterventionStudy] ([InterventionStudyIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionStudyURI] CHECK CONSTRAINT [FK_InterventionStudyURI_InterventionStudy]
GO
ALTER TABLE [edfi].[InterventionURI]  WITH NOCHECK ADD  CONSTRAINT [FK_InterventionURI_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[InterventionURI] CHECK CONSTRAINT [FK_InterventionURI_Intervention]
GO
ALTER TABLE [edfi].[LanguageDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_LanguageDescriptor_Descriptor_DescriptorId] FOREIGN KEY([LanguageDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LanguageDescriptor] CHECK CONSTRAINT [FK_LanguageDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[LanguageDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_LanguageDescriptor_LanguagesType_LanguageTypeId] FOREIGN KEY([LanguageTypeId])
REFERENCES [edfi].[LanguageType] ([LanguageTypeId])
GO
ALTER TABLE [edfi].[LanguageDescriptor] CHECK CONSTRAINT [FK_LanguageDescriptor_LanguagesType_LanguageTypeId]
GO
ALTER TABLE [edfi].[LearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningObjective_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[LearningObjective] CHECK CONSTRAINT [FK_LearningObjective_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[LearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningObjective_LearningObjective_ParentObjective] FOREIGN KEY([ParentObjective], [ParentAcademicSubjectDescriptorId], [ParentObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[LearningObjective] ([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[LearningObjective] CHECK CONSTRAINT [FK_LearningObjective_LearningObjective_ParentObjective]
GO
ALTER TABLE [edfi].[LearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningObjective_ObjectiveGradeLevelDescriptorId] FOREIGN KEY([ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[LearningObjective] CHECK CONSTRAINT [FK_LearningObjective_ObjectiveGradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningObjectiveContentStandard_EducationOrganization_MandatingEducationOrganizationId] FOREIGN KEY([MandatingEducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandard] CHECK CONSTRAINT [FK_LearningObjectiveContentStandard_EducationOrganization_MandatingEducationOrganizationId]
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningObjectiveContentStandard_LearningObjective_Objective] FOREIGN KEY([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[LearningObjective] ([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandard] CHECK CONSTRAINT [FK_LearningObjectiveContentStandard_LearningObjective_Objective]
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningObjectiveContentStandard_PublicationStatusType_PublicationStatusTypeId] FOREIGN KEY([PublicationStatusTypeId])
REFERENCES [edfi].[PublicationStatusType] ([PublicationStatusTypeId])
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandard] CHECK CONSTRAINT [FK_LearningObjectiveContentStandard_PublicationStatusType_PublicationStatusTypeId]
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandardAuthor]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningObjectiveContentStandardAuthor_LearningObjectiveContentStandard_Objective] FOREIGN KEY([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[LearningObjectiveContentStandard] ([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LearningObjectiveContentStandardAuthor] CHECK CONSTRAINT [FK_LearningObjectiveContentStandardAuthor_LearningObjectiveContentStandard_Objective]
GO
ALTER TABLE [edfi].[LearningObjectiveLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningObjectiveLearningStandard_LearningObjective] FOREIGN KEY([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[LearningObjective] ([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LearningObjectiveLearningStandard] CHECK CONSTRAINT [FK_LearningObjectiveLearningStandard_LearningObjective]
GO
ALTER TABLE [edfi].[LearningObjectiveLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningObjectiveLearningStandard_LearningStandard] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
GO
ALTER TABLE [edfi].[LearningObjectiveLearningStandard] CHECK CONSTRAINT [FK_LearningObjectiveLearningStandard_LearningStandard]
GO
ALTER TABLE [edfi].[LearningStandard]  WITH CHECK ADD  CONSTRAINT [FK_LearningStandard_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[LearningStandard] CHECK CONSTRAINT [FK_LearningStandard_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[LearningStandard]  WITH CHECK ADD  CONSTRAINT [FK_LearningStandard_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[LearningStandard] CHECK CONSTRAINT [FK_LearningStandard_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[LearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningStandard_LearningStandard_ParentLearningStandardId] FOREIGN KEY([ParentLearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
GO
ALTER TABLE [edfi].[LearningStandard] CHECK CONSTRAINT [FK_LearningStandard_LearningStandard_ParentLearningStandardId]
GO
ALTER TABLE [edfi].[LearningStandardContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningStandardContentStandard_EducationOrganization_MandatingEducationOrganizationReference] FOREIGN KEY([MandatingEducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[LearningStandardContentStandard] CHECK CONSTRAINT [FK_LearningStandardContentStandard_EducationOrganization_MandatingEducationOrganizationReference]
GO
ALTER TABLE [edfi].[LearningStandardContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningStandardContentStandard_LearningStandard_LearningStandardId] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LearningStandardContentStandard] CHECK CONSTRAINT [FK_LearningStandardContentStandard_LearningStandard_LearningStandardId]
GO
ALTER TABLE [edfi].[LearningStandardContentStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningStandardContentStandard_PublicationStatusType_PublicationStatusTypeId] FOREIGN KEY([PublicationStatusTypeId])
REFERENCES [edfi].[PublicationStatusType] ([PublicationStatusTypeId])
GO
ALTER TABLE [edfi].[LearningStandardContentStandard] CHECK CONSTRAINT [FK_LearningStandardContentStandard_PublicationStatusType_PublicationStatusTypeId]
GO
ALTER TABLE [edfi].[LearningStandardContentStandardAuthor]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningStandardContentStandardAuthor_LearningStandardContentStandard_LearningStandardId] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandardContentStandard] ([LearningStandardId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LearningStandardContentStandardAuthor] CHECK CONSTRAINT [FK_LearningStandardContentStandardAuthor_LearningStandardContentStandard_LearningStandardId]
GO
ALTER TABLE [edfi].[LearningStandardIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningStandardIdentificationCode_LearningStandard_LearningStandardId] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LearningStandardIdentificationCode] CHECK CONSTRAINT [FK_LearningStandardIdentificationCode_LearningStandard_LearningStandardId]
GO
ALTER TABLE [edfi].[LearningStandardPrerequisiteLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningStandardPrerequisiteLearningStandard_LearningStandard] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LearningStandardPrerequisiteLearningStandard] CHECK CONSTRAINT [FK_LearningStandardPrerequisiteLearningStandard_LearningStandard]
GO
ALTER TABLE [edfi].[LearningStandardPrerequisiteLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_LearningStandardPrerequisiteLearningStandard_LearningStandard_Prerequisite] FOREIGN KEY([PrerequisiteLearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
GO
ALTER TABLE [edfi].[LearningStandardPrerequisiteLearningStandard] CHECK CONSTRAINT [FK_LearningStandardPrerequisiteLearningStandard_LearningStandard_Prerequisite]
GO
ALTER TABLE [edfi].[LeaveEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_LeaveEvent_LeaveEventCategoryType_LeaveEventCategoryTypeId] FOREIGN KEY([LeaveEventCategoryTypeId])
REFERENCES [edfi].[LeaveEventCategoryType] ([LeaveEventCategoryTypeId])
GO
ALTER TABLE [edfi].[LeaveEvent] CHECK CONSTRAINT [FK_LeaveEvent_LeaveEventCategoryType_LeaveEventCategoryTypeId]
GO
ALTER TABLE [edfi].[LeaveEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_LeaveEvent_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[LeaveEvent] CHECK CONSTRAINT [FK_LeaveEvent_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[LevelDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_LevelDescriptor_Descriptor_DescriptorId] FOREIGN KEY([LevelDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LevelDescriptor] CHECK CONSTRAINT [FK_LevelDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[LevelDescriptorGradeLevel]  WITH CHECK ADD  CONSTRAINT [FK_LevelDescriptorGradeLevel_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[LevelDescriptorGradeLevel] CHECK CONSTRAINT [FK_LevelDescriptorGradeLevel_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[LevelDescriptorGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_LevelDescriptorGradeLevel_LevelDescriptor_LevelDescriptorId] FOREIGN KEY([LevelDescriptorId])
REFERENCES [edfi].[LevelDescriptor] ([LevelDescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LevelDescriptorGradeLevel] CHECK CONSTRAINT [FK_LevelDescriptorGradeLevel_LevelDescriptor_LevelDescriptorId]
GO
ALTER TABLE [edfi].[LevelOfEducationDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_LevelOfEducationDescriptor_Descriptor_DescriptorId] FOREIGN KEY([LevelOfEducationDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LevelOfEducationDescriptor] CHECK CONSTRAINT [FK_LevelOfEducationDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[LevelOfEducationDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_LevelOfEducationDescriptor_LevelOfEducationType_LevelOfEducationTypeId] FOREIGN KEY([LevelOfEducationTypeId])
REFERENCES [edfi].[LevelOfEducationType] ([LevelOfEducationTypeId])
GO
ALTER TABLE [edfi].[LevelOfEducationDescriptor] CHECK CONSTRAINT [FK_LevelOfEducationDescriptor_LevelOfEducationType_LevelOfEducationTypeId]
GO
ALTER TABLE [edfi].[LimitedEnglishProficiencyDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_LimitedEnglishProficiencyDescriptor_Descriptor_DescriptorId] FOREIGN KEY([LimitedEnglishProficiencyDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LimitedEnglishProficiencyDescriptor] CHECK CONSTRAINT [FK_LimitedEnglishProficiencyDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[LimitedEnglishProficiencyDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_LimitedEnglishProficiencyDescriptor_LimitedEnglishProficiencyType_LimitedEnglishProficiencyTypeId] FOREIGN KEY([LimitedEnglishProficiencyTypeId])
REFERENCES [edfi].[LimitedEnglishProficiencyType] ([LimitedEnglishProficiencyTypeId])
GO
ALTER TABLE [edfi].[LimitedEnglishProficiencyDescriptor] CHECK CONSTRAINT [FK_LimitedEnglishProficiencyDescriptor_LimitedEnglishProficiencyType_LimitedEnglishProficiencyTypeId]
GO
ALTER TABLE [edfi].[LocalEducationAgency]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgency_CharterStatusType_CharterStatusTypeId] FOREIGN KEY([CharterStatusTypeId])
REFERENCES [edfi].[CharterStatusType] ([CharterStatusTypeId])
GO
ALTER TABLE [edfi].[LocalEducationAgency] CHECK CONSTRAINT [FK_LocalEducationAgency_CharterStatusType_CharterStatusTypeId]
GO
ALTER TABLE [edfi].[LocalEducationAgency]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgency_EducationOrganization_LocalEducationAgencyId] FOREIGN KEY([LocalEducationAgencyId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LocalEducationAgency] CHECK CONSTRAINT [FK_LocalEducationAgency_EducationOrganization_LocalEducationAgencyId]
GO
ALTER TABLE [edfi].[LocalEducationAgency]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgency_EducationServiceCenter_EducationServiceCenterId] FOREIGN KEY([EducationServiceCenterId])
REFERENCES [edfi].[EducationServiceCenter] ([EducationServiceCenterId])
GO
ALTER TABLE [edfi].[LocalEducationAgency] CHECK CONSTRAINT [FK_LocalEducationAgency_EducationServiceCenter_EducationServiceCenterId]
GO
ALTER TABLE [edfi].[LocalEducationAgency]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgency_LocalEducationAgency_LocalEducationAgencyId] FOREIGN KEY([ParentLocalEducationAgencyId])
REFERENCES [edfi].[LocalEducationAgency] ([LocalEducationAgencyId])
GO
ALTER TABLE [edfi].[LocalEducationAgency] CHECK CONSTRAINT [FK_LocalEducationAgency_LocalEducationAgency_LocalEducationAgencyId]
GO
ALTER TABLE [edfi].[LocalEducationAgency]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgency_LocalEducationAgencyCategoryType_LocalEducationAgencyCategoryTypeId] FOREIGN KEY([LocalEducationAgencyCategoryTypeId])
REFERENCES [edfi].[LocalEducationAgencyCategoryType] ([LocalEducationAgencyCategoryTypeId])
GO
ALTER TABLE [edfi].[LocalEducationAgency] CHECK CONSTRAINT [FK_LocalEducationAgency_LocalEducationAgencyCategoryType_LocalEducationAgencyCategoryTypeId]
GO
ALTER TABLE [edfi].[LocalEducationAgency]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgency_StateEducationAgency_StateEducationAgencyId] FOREIGN KEY([StateEducationAgencyId])
REFERENCES [edfi].[StateEducationAgency] ([StateEducationAgencyId])
GO
ALTER TABLE [edfi].[LocalEducationAgency] CHECK CONSTRAINT [FK_LocalEducationAgency_StateEducationAgency_StateEducationAgencyId]
GO
ALTER TABLE [edfi].[LocalEducationAgencyAccountability]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgencyAccountability_GunFreeSchoolsActReportingStatusType_GunFreeSchoolsActReportingStatusTypeId] FOREIGN KEY([GunFreeSchoolsActReportingStatusTypeId])
REFERENCES [edfi].[GunFreeSchoolsActReportingStatusType] ([GunFreeSchoolsActReportingStatusTypeId])
GO
ALTER TABLE [edfi].[LocalEducationAgencyAccountability] CHECK CONSTRAINT [FK_LocalEducationAgencyAccountability_GunFreeSchoolsActReportingStatusType_GunFreeSchoolsActReportingStatusTypeId]
GO
ALTER TABLE [edfi].[LocalEducationAgencyAccountability]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgencyAccountability_LocalEducationAgency_LocalEducationAgencyId] FOREIGN KEY([LocalEducationAgencyId])
REFERENCES [edfi].[LocalEducationAgency] ([LocalEducationAgencyId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[LocalEducationAgencyAccountability] CHECK CONSTRAINT [FK_LocalEducationAgencyAccountability_LocalEducationAgency_LocalEducationAgencyId]
GO
ALTER TABLE [edfi].[LocalEducationAgencyAccountability]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgencyAccountability_SchoolChoiceImplementStatusType_SchoolChoiceImplementationStatusTypeId] FOREIGN KEY([SchoolChoiceImplementStatusTypeId])
REFERENCES [edfi].[SchoolChoiceImplementStatusType] ([SchoolChoiceImplementStatusTypeId])
GO
ALTER TABLE [edfi].[LocalEducationAgencyAccountability] CHECK CONSTRAINT [FK_LocalEducationAgencyAccountability_SchoolChoiceImplementStatusType_SchoolChoiceImplementationStatusTypeId]
GO
ALTER TABLE [edfi].[LocalEducationAgencyAccountability]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgencyAccountability_SchoolYearType_SchoolYear] FOREIGN KEY([SchoolYear])
REFERENCES [edfi].[SchoolYearType] ([SchoolYear])
GO
ALTER TABLE [edfi].[LocalEducationAgencyAccountability] CHECK CONSTRAINT [FK_LocalEducationAgencyAccountability_SchoolYearType_SchoolYear]
GO
ALTER TABLE [edfi].[LocalEducationAgencyFederalFunds]  WITH NOCHECK ADD  CONSTRAINT [FK_LocalEducationAgencyFederalFunds_LocalEducationAgency_LocalEducationAgencyId] FOREIGN KEY([LocalEducationAgencyId])
REFERENCES [edfi].[LocalEducationAgency] ([LocalEducationAgencyId])
GO
ALTER TABLE [edfi].[LocalEducationAgencyFederalFunds] CHECK CONSTRAINT [FK_LocalEducationAgencyFederalFunds_LocalEducationAgency_LocalEducationAgencyId]
GO
ALTER TABLE [edfi].[Location]  WITH NOCHECK ADD  CONSTRAINT [FK_Location_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[Location] CHECK CONSTRAINT [FK_Location_School_SchoolId]
GO
ALTER TABLE [edfi].[ObjectiveAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessment_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
GO
ALTER TABLE [edfi].[ObjectiveAssessment] CHECK CONSTRAINT [FK_ObjectiveAssessment_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[ObjectiveAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessment_ObjectiveAssessment] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [ParentIdentificationCode])
REFERENCES [edfi].[ObjectiveAssessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
GO
ALTER TABLE [edfi].[ObjectiveAssessment] CHECK CONSTRAINT [FK_ObjectiveAssessment_ObjectiveAssessment]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentAssessmentItem]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentAssessmentItem_AssessmentItem] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AssessmentItemIdentificationCode])
REFERENCES [edfi].[AssessmentItem] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
GO
ALTER TABLE [edfi].[ObjectiveAssessmentAssessmentItem] CHECK CONSTRAINT [FK_ObjectiveAssessmentAssessmentItem_AssessmentItem]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentAssessmentItem]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentAssessmentItem_ObjectiveAssessment] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
REFERENCES [edfi].[ObjectiveAssessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ObjectiveAssessmentAssessmentItem] CHECK CONSTRAINT [FK_ObjectiveAssessmentAssessmentItem_ObjectiveAssessment]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentLearningObjective_LearningObjective_Objective] FOREIGN KEY([Objective], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId])
REFERENCES [edfi].[LearningObjective] ([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningObjective] CHECK CONSTRAINT [FK_ObjectiveAssessmentLearningObjective_LearningObjective_Objective]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentLearningObjective_ObjectiveAssessment] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
REFERENCES [edfi].[ObjectiveAssessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningObjective] CHECK CONSTRAINT [FK_ObjectiveAssessmentLearningObjective_ObjectiveAssessment]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentLearningStandard_LearningStandard_LearningStandardId] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningStandard] CHECK CONSTRAINT [FK_ObjectiveAssessmentLearningStandard_LearningStandard_LearningStandardId]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentLearningStandard_ObjectiveAssessment] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
REFERENCES [edfi].[ObjectiveAssessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ObjectiveAssessmentLearningStandard] CHECK CONSTRAINT [FK_ObjectiveAssessmentLearningStandard_ObjectiveAssessment]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentPerformanceLevel_AssessmentReportingMethodType_AssessmentReportingMethodTypeId] FOREIGN KEY([AssessmentReportingMethodTypeId])
REFERENCES [edfi].[AssessmentReportingMethodType] ([AssessmentReportingMethodTypeId])
GO
ALTER TABLE [edfi].[ObjectiveAssessmentPerformanceLevel] CHECK CONSTRAINT [FK_ObjectiveAssessmentPerformanceLevel_AssessmentReportingMethodType_AssessmentReportingMethodTypeId]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentPerformanceLevel_ObjectiveAssessment] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
REFERENCES [edfi].[ObjectiveAssessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ObjectiveAssessmentPerformanceLevel] CHECK CONSTRAINT [FK_ObjectiveAssessmentPerformanceLevel_ObjectiveAssessment]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentPerformanceLevel_PerformanceLevelDescriptor_PerformanceLevelDescriptorId] FOREIGN KEY([PerformanceLevelDescriptorId])
REFERENCES [edfi].[PerformanceLevelDescriptor] ([PerformanceLevelDescriptorId])
GO
ALTER TABLE [edfi].[ObjectiveAssessmentPerformanceLevel] CHECK CONSTRAINT [FK_ObjectiveAssessmentPerformanceLevel_PerformanceLevelDescriptor_PerformanceLevelDescriptorId]
GO
ALTER TABLE [edfi].[ObjectiveAssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_ObjectiveAssessmentPerformanceLevel_ResultDatatypeType_ResultDatatypeTypeId] FOREIGN KEY([ResultDatatypeTypeId])
REFERENCES [edfi].[ResultDatatypeType] ([ResultDatatypeTypeId])
GO
ALTER TABLE [edfi].[ObjectiveAssessmentPerformanceLevel] CHECK CONSTRAINT [FK_ObjectiveAssessmentPerformanceLevel_ResultDatatypeType_ResultDatatypeTypeId]
GO
ALTER TABLE [edfi].[OpenStaffPosition]  WITH NOCHECK ADD  CONSTRAINT [FK_OpenStaffPosition_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[OpenStaffPosition] CHECK CONSTRAINT [FK_OpenStaffPosition_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[OpenStaffPosition]  WITH NOCHECK ADD  CONSTRAINT [FK_OpenStaffPosition_EmploymentStatusDescriptor_EmploymentStatusDescriptorId] FOREIGN KEY([EmploymentStatusDescriptorId])
REFERENCES [edfi].[EmploymentStatusDescriptor] ([EmploymentStatusDescriptorId])
GO
ALTER TABLE [edfi].[OpenStaffPosition] CHECK CONSTRAINT [FK_OpenStaffPosition_EmploymentStatusDescriptor_EmploymentStatusDescriptorId]
GO
ALTER TABLE [edfi].[OpenStaffPosition]  WITH NOCHECK ADD  CONSTRAINT [FK_OpenStaffPosition_PostingResultType_PostingResultTypeId] FOREIGN KEY([PostingResultTypeId])
REFERENCES [edfi].[PostingResultType] ([PostingResultTypeId])
GO
ALTER TABLE [edfi].[OpenStaffPosition] CHECK CONSTRAINT [FK_OpenStaffPosition_PostingResultType_PostingResultTypeId]
GO
ALTER TABLE [edfi].[OpenStaffPosition]  WITH NOCHECK ADD  CONSTRAINT [FK_OpenStaffPosition_ProgramAssignmentDescriptor_ProgramAssignmentDescriptorId] FOREIGN KEY([ProgramAssignmentDescriptorId])
REFERENCES [edfi].[ProgramAssignmentDescriptor] ([ProgramAssignmentDescriptorId])
GO
ALTER TABLE [edfi].[OpenStaffPosition] CHECK CONSTRAINT [FK_OpenStaffPosition_ProgramAssignmentDescriptor_ProgramAssignmentDescriptorId]
GO
ALTER TABLE [edfi].[OpenStaffPosition]  WITH CHECK ADD  CONSTRAINT [FK_OpenStaffPosition_StaffClassificationDescriptorId] FOREIGN KEY([StaffClassificationDescriptorId])
REFERENCES [edfi].[StaffClassificationDescriptor] ([StaffClassificationDescriptorId])
GO
ALTER TABLE [edfi].[OpenStaffPosition] CHECK CONSTRAINT [FK_OpenStaffPosition_StaffClassificationDescriptorId]
GO
ALTER TABLE [edfi].[OpenStaffPositionAcademicSubject]  WITH CHECK ADD  CONSTRAINT [FK_OpenStaffPositionAcademicSubject_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[OpenStaffPositionAcademicSubject] CHECK CONSTRAINT [FK_OpenStaffPositionAcademicSubject_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[OpenStaffPositionAcademicSubject]  WITH NOCHECK ADD  CONSTRAINT [FK_OpenStaffPositionAcademicSubjects_OpenStaffPosition_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [EmploymentStatusDescriptorId], [StaffClassificationDescriptorId], [RequisitionNumber], [DatePosted])
REFERENCES [edfi].[OpenStaffPosition] ([EducationOrganizationId], [EmploymentStatusDescriptorId], [StaffClassificationDescriptorId], [RequisitionNumber], [DatePosted])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[OpenStaffPositionAcademicSubject] CHECK CONSTRAINT [FK_OpenStaffPositionAcademicSubjects_OpenStaffPosition_EducationOrganizationId]
GO
ALTER TABLE [edfi].[OpenStaffPositionInstructionalGradeLevel]  WITH CHECK ADD  CONSTRAINT [FK_OpenStaffPositionInstructionalGradeLevel_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[OpenStaffPositionInstructionalGradeLevel] CHECK CONSTRAINT [FK_OpenStaffPositionInstructionalGradeLevel_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[OpenStaffPositionInstructionalGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_OpenStaffPositionInstructionalGradeLevels_OpenStaffPosition_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [EmploymentStatusDescriptorId], [StaffClassificationDescriptorId], [RequisitionNumber], [DatePosted])
REFERENCES [edfi].[OpenStaffPosition] ([EducationOrganizationId], [EmploymentStatusDescriptorId], [StaffClassificationDescriptorId], [RequisitionNumber], [DatePosted])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[OpenStaffPositionInstructionalGradeLevel] CHECK CONSTRAINT [FK_OpenStaffPositionInstructionalGradeLevels_OpenStaffPosition_EducationOrganizationId]
GO
ALTER TABLE [edfi].[Parent]  WITH NOCHECK ADD  CONSTRAINT [FK_Parent_SexType_SexTypeId] FOREIGN KEY([SexTypeId])
REFERENCES [edfi].[SexType] ([SexTypeId])
GO
ALTER TABLE [edfi].[Parent] CHECK CONSTRAINT [FK_Parent_SexType_SexTypeId]
GO
ALTER TABLE [edfi].[ParentAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentAddress_AddressType_AddressTypeId] FOREIGN KEY([AddressTypeId])
REFERENCES [edfi].[AddressType] ([AddressTypeId])
GO
ALTER TABLE [edfi].[ParentAddress] CHECK CONSTRAINT [FK_ParentAddress_AddressType_AddressTypeId]
GO
ALTER TABLE [edfi].[ParentAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentAddress_Parent_ParentUSI] FOREIGN KEY([ParentUSI])
REFERENCES [edfi].[Parent] ([ParentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ParentAddress] CHECK CONSTRAINT [FK_ParentAddress_Parent_ParentUSI]
GO
ALTER TABLE [edfi].[ParentAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentAddress_StateAbbreviationType_StateAbbreviationTypeId] FOREIGN KEY([StateAbbreviationTypeId])
REFERENCES [edfi].[StateAbbreviationType] ([StateAbbreviationTypeId])
GO
ALTER TABLE [edfi].[ParentAddress] CHECK CONSTRAINT [FK_ParentAddress_StateAbbreviationType_StateAbbreviationTypeId]
GO
ALTER TABLE [edfi].[ParentElectronicMail]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentElectronicMail_ElectronicMailType_ElectronicMailTypeId] FOREIGN KEY([ElectronicMailTypeId])
REFERENCES [edfi].[ElectronicMailType] ([ElectronicMailTypeId])
GO
ALTER TABLE [edfi].[ParentElectronicMail] CHECK CONSTRAINT [FK_ParentElectronicMail_ElectronicMailType_ElectronicMailTypeId]
GO
ALTER TABLE [edfi].[ParentElectronicMail]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentElectronicMail_Parent_ParentUSI] FOREIGN KEY([ParentUSI])
REFERENCES [edfi].[Parent] ([ParentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ParentElectronicMail] CHECK CONSTRAINT [FK_ParentElectronicMail_Parent_ParentUSI]
GO
ALTER TABLE [edfi].[ParentIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentIdentificationDocument_CountryType_IssuerCountryTypeId] FOREIGN KEY([IssuerCountryTypeId])
REFERENCES [edfi].[CountryType] ([CountryTypeId])
GO
ALTER TABLE [edfi].[ParentIdentificationDocument] CHECK CONSTRAINT [FK_ParentIdentificationDocument_CountryType_IssuerCountryTypeId]
GO
ALTER TABLE [edfi].[ParentIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentIdentificationDocument_IdentificationDocumentUseType_IdentificationDocumentUseTypeId] FOREIGN KEY([IdentificationDocumentUseTypeId])
REFERENCES [edfi].[IdentificationDocumentUseType] ([IdentificationDocumentUseTypeId])
GO
ALTER TABLE [edfi].[ParentIdentificationDocument] CHECK CONSTRAINT [FK_ParentIdentificationDocument_IdentificationDocumentUseType_IdentificationDocumentUseTypeId]
GO
ALTER TABLE [edfi].[ParentIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentIdentificationDocument_Parent_ParentUSI] FOREIGN KEY([ParentUSI])
REFERENCES [edfi].[Parent] ([ParentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ParentIdentificationDocument] CHECK CONSTRAINT [FK_ParentIdentificationDocument_Parent_ParentUSI]
GO
ALTER TABLE [edfi].[ParentIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentIdentificationDocument_PersonalInformationVerificationType_PersonalInformationVerificationTypeId] FOREIGN KEY([PersonalInformationVerificationTypeId])
REFERENCES [edfi].[PersonalInformationVerificationType] ([PersonalInformationVerificationTypeId])
GO
ALTER TABLE [edfi].[ParentIdentificationDocument] CHECK CONSTRAINT [FK_ParentIdentificationDocument_PersonalInformationVerificationType_PersonalInformationVerificationTypeId]
GO
ALTER TABLE [edfi].[ParentInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentInternationalAddress_AddressType_AddressTypeId] FOREIGN KEY([AddressTypeId])
REFERENCES [edfi].[AddressType] ([AddressTypeId])
GO
ALTER TABLE [edfi].[ParentInternationalAddress] CHECK CONSTRAINT [FK_ParentInternationalAddress_AddressType_AddressTypeId]
GO
ALTER TABLE [edfi].[ParentInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentInternationalAddress_CountryType_CountryTypeId] FOREIGN KEY([CountryTypeId])
REFERENCES [edfi].[CountryType] ([CountryTypeId])
GO
ALTER TABLE [edfi].[ParentInternationalAddress] CHECK CONSTRAINT [FK_ParentInternationalAddress_CountryType_CountryTypeId]
GO
ALTER TABLE [edfi].[ParentInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentInternationalAddress_Parent_ParentUSI] FOREIGN KEY([ParentUSI])
REFERENCES [edfi].[Parent] ([ParentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ParentInternationalAddress] CHECK CONSTRAINT [FK_ParentInternationalAddress_Parent_ParentUSI]
GO
ALTER TABLE [edfi].[ParentOtherName]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentOtherName_OtherNameType_OtherNameTypeId] FOREIGN KEY([OtherNameTypeId])
REFERENCES [edfi].[OtherNameType] ([OtherNameTypeId])
GO
ALTER TABLE [edfi].[ParentOtherName] CHECK CONSTRAINT [FK_ParentOtherName_OtherNameType_OtherNameTypeId]
GO
ALTER TABLE [edfi].[ParentOtherName]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentOtherName_Parent_ParentUSI] FOREIGN KEY([ParentUSI])
REFERENCES [edfi].[Parent] ([ParentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ParentOtherName] CHECK CONSTRAINT [FK_ParentOtherName_Parent_ParentUSI]
GO
ALTER TABLE [edfi].[ParentTelephone]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentTelephone_Parent_ParentUSI] FOREIGN KEY([ParentUSI])
REFERENCES [edfi].[Parent] ([ParentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ParentTelephone] CHECK CONSTRAINT [FK_ParentTelephone_Parent_ParentUSI]
GO
ALTER TABLE [edfi].[ParentTelephone]  WITH NOCHECK ADD  CONSTRAINT [FK_ParentTelephone_TelephoneNumberType_TelephoneNumberTypeId] FOREIGN KEY([TelephoneNumberTypeId])
REFERENCES [edfi].[TelephoneNumberType] ([TelephoneNumberTypeId])
GO
ALTER TABLE [edfi].[ParentTelephone] CHECK CONSTRAINT [FK_ParentTelephone_TelephoneNumberType_TelephoneNumberTypeId]
GO
ALTER TABLE [edfi].[Payroll]  WITH NOCHECK ADD  CONSTRAINT [FK_Payroll_Account_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [AccountNumber], [FiscalYear])
REFERENCES [edfi].[Account] ([EducationOrganizationId], [AccountNumber], [FiscalYear])
GO
ALTER TABLE [edfi].[Payroll] CHECK CONSTRAINT [FK_Payroll_Account_EducationOrganizationId]
GO
ALTER TABLE [edfi].[Payroll]  WITH NOCHECK ADD  CONSTRAINT [FK_Payroll_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[Payroll] CHECK CONSTRAINT [FK_Payroll_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[PerformanceLevelDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_PerformanceLevelDescriptor_Descriptor_DescriptorId] FOREIGN KEY([PerformanceLevelDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[PerformanceLevelDescriptor] CHECK CONSTRAINT [FK_PerformanceLevelDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[PerformanceLevelDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_PerformanceLevelDescriptor_PerformanceBaseType_PerformanceBaseConversionTypeId] FOREIGN KEY([PerformanceBaseConversionTypeId])
REFERENCES [edfi].[PerformanceBaseConversionType] ([PerformanceBaseConversionTypeId])
GO
ALTER TABLE [edfi].[PerformanceLevelDescriptor] CHECK CONSTRAINT [FK_PerformanceLevelDescriptor_PerformanceBaseType_PerformanceBaseConversionTypeId]
GO
ALTER TABLE [edfi].[PostSecondaryEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_PostSecondaryEvent_PostSecondaryEventCategoryType_PostSecondaryEventCategoryTypeId] FOREIGN KEY([PostSecondaryEventCategoryTypeId])
REFERENCES [edfi].[PostSecondaryEventCategoryType] ([PostSecondaryEventCategoryTypeId])
GO
ALTER TABLE [edfi].[PostSecondaryEvent] CHECK CONSTRAINT [FK_PostSecondaryEvent_PostSecondaryEventCategoryType_PostSecondaryEventCategoryTypeId]
GO
ALTER TABLE [edfi].[PostSecondaryEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_PostSecondaryEvent_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[PostSecondaryEvent] CHECK CONSTRAINT [FK_PostSecondaryEvent_Student_StudentUSI]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitution]  WITH CHECK ADD  CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitution_AdministrativeFundingControlDescriptorId] FOREIGN KEY([AdministrativeFundingControlDescriptorId])
REFERENCES [edfi].[AdministrativeFundingControlDescriptor] ([AdministrativeFundingControlDescriptorId])
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitution] CHECK CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitution_AdministrativeFundingControlDescriptorId]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitution]  WITH NOCHECK ADD  CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitution_PostSecondaryEvent] FOREIGN KEY([StudentUSI], [PostSecondaryEventCategoryTypeId], [EventDate])
REFERENCES [edfi].[PostSecondaryEvent] ([StudentUSI], [PostSecondaryEventCategoryTypeId], [EventDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitution] CHECK CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitution_PostSecondaryEvent]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitution]  WITH NOCHECK ADD  CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitution_PostSecondaryInstitutionLevelType_PostSecondaryInstitutionLevelTypeId] FOREIGN KEY([PostSecondaryInstitutionLevelTypeId])
REFERENCES [edfi].[PostSecondaryInstitutionLevelType] ([PostSecondaryInstitutionLevelTypeId])
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitution] CHECK CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitution_PostSecondaryInstitutionLevelType_PostSecondaryInstitutionLevelTypeId]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitutionIdentificationCode_EducationOrganizationIdentificationSystemType] FOREIGN KEY([EducationOrganizationIdentificationSystemTypeId])
REFERENCES [edfi].[EducationOrganizationIdentificationSystemType] ([EducationOrganizationIdentificationSystemTypeId])
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionIdentificationCode] CHECK CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitutionIdentificationCode_EducationOrganizationIdentificationSystemType]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitutionIdentificationCode_PostSecondaryEventPostSecondaryInstitution] FOREIGN KEY([StudentUSI], [PostSecondaryEventCategoryTypeId], [EventDate])
REFERENCES [edfi].[PostSecondaryEventPostSecondaryInstitution] ([StudentUSI], [PostSecondaryEventCategoryTypeId], [EventDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionIdentificationCode] CHECK CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitutionIdentificationCode_PostSecondaryEventPostSecondaryInstitution]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction]  WITH NOCHECK ADD  CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction_MediumOfInstructionType_MediumOfInstructionTypeId] FOREIGN KEY([MediumOfInstructionTypeId])
REFERENCES [edfi].[MediumOfInstructionType] ([MediumOfInstructionTypeId])
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction] CHECK CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction_MediumOfInstructionType_MediumOfInstructionTypeId]
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction]  WITH NOCHECK ADD  CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction_PostSecondaryEventPostSecondaryInstitution] FOREIGN KEY([StudentUSI], [PostSecondaryEventCategoryTypeId], [EventDate])
REFERENCES [edfi].[PostSecondaryEventPostSecondaryInstitution] ([StudentUSI], [PostSecondaryEventCategoryTypeId], [EventDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction] CHECK CONSTRAINT [FK_PostSecondaryEventPostSecondaryInstitutionMediumOfInstruction_PostSecondaryEventPostSecondaryInstitution]
GO
ALTER TABLE [edfi].[Program]  WITH NOCHECK ADD  CONSTRAINT [FK_Program_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[Program] CHECK CONSTRAINT [FK_Program_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[Program]  WITH NOCHECK ADD  CONSTRAINT [FK_Program_ProgramSponsorType_ProgramSponsorTypeId] FOREIGN KEY([ProgramSponsorTypeId])
REFERENCES [edfi].[ProgramSponsorType] ([ProgramSponsorTypeId])
GO
ALTER TABLE [edfi].[Program] CHECK CONSTRAINT [FK_Program_ProgramSponsorType_ProgramSponsorTypeId]
GO
ALTER TABLE [edfi].[Program]  WITH NOCHECK ADD  CONSTRAINT [FK_Program_ProgramType_ProgramTypeId] FOREIGN KEY([ProgramTypeId])
REFERENCES [edfi].[ProgramType] ([ProgramTypeId])
GO
ALTER TABLE [edfi].[Program] CHECK CONSTRAINT [FK_Program_ProgramType_ProgramTypeId]
GO
ALTER TABLE [edfi].[ProgramAssignmentDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramAssignmentDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ProgramAssignmentDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ProgramAssignmentDescriptor] CHECK CONSTRAINT [FK_ProgramAssignmentDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[ProgramAssignmentDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramAssignmentDescriptor_ProgramAssignmentType_ProgramAssignmentTypeId] FOREIGN KEY([ProgramAssignmentTypeId])
REFERENCES [edfi].[ProgramAssignmentType] ([ProgramAssignmentTypeId])
GO
ALTER TABLE [edfi].[ProgramAssignmentDescriptor] CHECK CONSTRAINT [FK_ProgramAssignmentDescriptor_ProgramAssignmentType_ProgramAssignmentTypeId]
GO
ALTER TABLE [edfi].[ProgramCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramCharacteristic_Program_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ProgramCharacteristic] CHECK CONSTRAINT [FK_ProgramCharacteristic_Program_EducationOrganizationId]
GO
ALTER TABLE [edfi].[ProgramCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramCharacteristic_ProgramCharacteristicDescriptor_ProgramCharacteristicDescriptorId] FOREIGN KEY([ProgramCharacteristicDescriptorId])
REFERENCES [edfi].[ProgramCharacteristicDescriptor] ([ProgramCharacteristicDescriptorId])
GO
ALTER TABLE [edfi].[ProgramCharacteristic] CHECK CONSTRAINT [FK_ProgramCharacteristic_ProgramCharacteristicDescriptor_ProgramCharacteristicDescriptorId]
GO
ALTER TABLE [edfi].[ProgramCharacteristicDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramCharacteristicDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ProgramCharacteristicDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ProgramCharacteristicDescriptor] CHECK CONSTRAINT [FK_ProgramCharacteristicDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[ProgramCharacteristicDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramCharacteristicDescriptor_ProgramCharacteristicType_ProgramCharacteristicTypeId] FOREIGN KEY([ProgramCharacteristicTypeId])
REFERENCES [edfi].[ProgramCharacteristicType] ([ProgramCharacteristicTypeId])
GO
ALTER TABLE [edfi].[ProgramCharacteristicDescriptor] CHECK CONSTRAINT [FK_ProgramCharacteristicDescriptor_ProgramCharacteristicType_ProgramCharacteristicTypeId]
GO
ALTER TABLE [edfi].[ProgramLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramLearningStandard_LearningObjective_Objective] FOREIGN KEY([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[LearningObjective] ([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[ProgramLearningObjective] CHECK CONSTRAINT [FK_ProgramLearningStandard_LearningObjective_Objective]
GO
ALTER TABLE [edfi].[ProgramLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramLearningStandard_Program_ProgramTypeId] FOREIGN KEY([EducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ProgramLearningObjective] CHECK CONSTRAINT [FK_ProgramLearningStandard_Program_ProgramTypeId]
GO
ALTER TABLE [edfi].[ProgramLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramLearningObjective_LearningStandard_LearningStandardId] FOREIGN KEY([LearningStandardId])
REFERENCES [edfi].[LearningStandard] ([LearningStandardId])
GO
ALTER TABLE [edfi].[ProgramLearningStandard] CHECK CONSTRAINT [FK_ProgramLearningObjective_LearningStandard_LearningStandardId]
GO
ALTER TABLE [edfi].[ProgramLearningStandard]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramLearningObjective_Program_ProgramTypeId] FOREIGN KEY([EducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ProgramLearningStandard] CHECK CONSTRAINT [FK_ProgramLearningObjective_Program_ProgramTypeId]
GO
ALTER TABLE [edfi].[ProgramService]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramService_Program_ProgramTypeId] FOREIGN KEY([EducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ProgramService] CHECK CONSTRAINT [FK_ProgramService_Program_ProgramTypeId]
GO
ALTER TABLE [edfi].[ProgramService]  WITH NOCHECK ADD  CONSTRAINT [FK_ProgramService_ServiceDescriptor_ServiceDescriptorId] FOREIGN KEY([ServiceDescriptorId])
REFERENCES [edfi].[ServiceDescriptor] ([ServiceDescriptorId])
GO
ALTER TABLE [edfi].[ProgramService] CHECK CONSTRAINT [FK_ProgramService_ServiceDescriptor_ServiceDescriptorId]
GO
ALTER TABLE [edfi].[ReasonExitedDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ReasonExitedDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ReasonExitedDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ReasonExitedDescriptor] CHECK CONSTRAINT [FK_ReasonExitedDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[ReasonExitedDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ReasonExitedDescriptor_ReasonExitedType_ReasonExitedTypeId] FOREIGN KEY([ReasonExitedTypeId])
REFERENCES [edfi].[ReasonExitedType] ([ReasonExitedTypeId])
GO
ALTER TABLE [edfi].[ReasonExitedDescriptor] CHECK CONSTRAINT [FK_ReasonExitedDescriptor_ReasonExitedType_ReasonExitedTypeId]
GO
ALTER TABLE [edfi].[ReportCard]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCard_GradingPeriod_EducationOrganizationId] FOREIGN KEY([GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
REFERENCES [edfi].[GradingPeriod] ([EducationOrganizationId], [GradingPeriodDescriptorId], [BeginDate])
GO
ALTER TABLE [edfi].[ReportCard] CHECK CONSTRAINT [FK_ReportCard_GradingPeriod_EducationOrganizationId]
GO
ALTER TABLE [edfi].[ReportCard]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCard_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[ReportCard] CHECK CONSTRAINT [FK_ReportCard_Student_StudentUSI]
GO
ALTER TABLE [edfi].[ReportCardGrade]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCardGrade_Grade_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate], [GradingPeriodDescriptorId], [GradingPeriodBeginDate], [GradingPeriodEducationOrganizationId], [GradeTypeId])
REFERENCES [edfi].[Grade] ([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate], [GradingPeriodDescriptorId], [GradingPeriodBeginDate], [GradingPeriodEducationOrganizationId], [GradeTypeId])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[ReportCardGrade] CHECK CONSTRAINT [FK_ReportCardGrade_Grade_StudentUSI]
GO
ALTER TABLE [edfi].[ReportCardGrade]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCardGrade_ReportCard] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
REFERENCES [edfi].[ReportCard] ([StudentUSI], [EducationOrganizationId], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ReportCardGrade] CHECK CONSTRAINT [FK_ReportCardGrade_ReportCard]
GO
ALTER TABLE [edfi].[ReportCardStudentCompetencyObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCardStudentCompetencyObjective_ReportCard] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
REFERENCES [edfi].[ReportCard] ([StudentUSI], [EducationOrganizationId], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ReportCardStudentCompetencyObjective] CHECK CONSTRAINT [FK_ReportCardStudentCompetencyObjective_ReportCard]
GO
ALTER TABLE [edfi].[ReportCardStudentCompetencyObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCardStudentCompetencyObjective_StudentCompetencyObjective_StudentUSI] FOREIGN KEY([StudentUSI], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate], [Objective], [ObjectiveGradeLevelDescriptorId], [EducationOrganizationId])
REFERENCES [edfi].[StudentCompetencyObjective] ([StudentUSI], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate], [Objective], [ObjectiveGradeLevelDescriptorId], [ObjectiveEducationOrganizationId])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[ReportCardStudentCompetencyObjective] CHECK CONSTRAINT [FK_ReportCardStudentCompetencyObjective_StudentCompetencyObjective_StudentUSI]
GO
ALTER TABLE [edfi].[ReportCardStudentLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCardStudentLearningObjective_ReportCard] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
REFERENCES [edfi].[ReportCard] ([StudentUSI], [EducationOrganizationId], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ReportCardStudentLearningObjective] CHECK CONSTRAINT [FK_ReportCardStudentLearningObjective_ReportCard]
GO
ALTER TABLE [edfi].[ReportCardStudentLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCardStudentLearningObjective_StudentLearningObjective_StudentUSI] FOREIGN KEY([StudentUSI], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate], [Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[StudentLearningObjective] ([StudentUSI], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate], [Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[ReportCardStudentLearningObjective] CHECK CONSTRAINT [FK_ReportCardStudentLearningObjective_StudentLearningObjective_StudentUSI]
GO
ALTER TABLE [edfi].[ReporterDescriptionDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ReporterDescriptionDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ReporterDescriptionDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ReporterDescriptionDescriptor] CHECK CONSTRAINT [FK_ReporterDescriptionDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[ReporterDescriptionDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ReporterDescriptionDescriptor_ReporterDescriptionType_ReporterDescriptionTypeId] FOREIGN KEY([ReporterDescriptionTypeId])
REFERENCES [edfi].[ReporterDescriptionType] ([ReporterDescriptionTypeId])
GO
ALTER TABLE [edfi].[ReporterDescriptionDescriptor] CHECK CONSTRAINT [FK_ReporterDescriptionDescriptor_ReporterDescriptionType_ReporterDescriptionTypeId]
GO
ALTER TABLE [edfi].[ResidencyStatusDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ResidencyStatusDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ResidencyStatusDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ResidencyStatusDescriptor] CHECK CONSTRAINT [FK_ResidencyStatusDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[ResidencyStatusDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ResidencyStatusDescriptor_ResidencyStatusType_ResidencyStatusTypeId] FOREIGN KEY([ResidencyStatusTypeId])
REFERENCES [edfi].[ResidencyStatusType] ([ResidencyStatusTypeId])
GO
ALTER TABLE [edfi].[ResidencyStatusDescriptor] CHECK CONSTRAINT [FK_ResidencyStatusDescriptor_ResidencyStatusType_ResidencyStatusTypeId]
GO
ALTER TABLE [edfi].[ResponsibilityDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ResponsibilityDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ResponsibilityDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ResponsibilityDescriptor] CHECK CONSTRAINT [FK_ResponsibilityDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[ResponsibilityDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ResponsibilityDescriptor_ResponsibilityType_ResponsibilityTypeId] FOREIGN KEY([ResponsibilityTypeId])
REFERENCES [edfi].[ResponsibilityType] ([ResponsibilityTypeId])
GO
ALTER TABLE [edfi].[ResponsibilityDescriptor] CHECK CONSTRAINT [FK_ResponsibilityDescriptor_ResponsibilityType_ResponsibilityTypeId]
GO
ALTER TABLE [edfi].[RestraintEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_RestraintEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId] FOREIGN KEY([EducationalEnvironmentTypeId])
REFERENCES [edfi].[EducationalEnvironmentType] ([EducationalEnvironmentTypeId])
GO
ALTER TABLE [edfi].[RestraintEvent] CHECK CONSTRAINT [FK_RestraintEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId]
GO
ALTER TABLE [edfi].[RestraintEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_RestraintEvent_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[RestraintEvent] CHECK CONSTRAINT [FK_RestraintEvent_School_SchoolId]
GO
ALTER TABLE [edfi].[RestraintEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_RestraintEvent_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[RestraintEvent] CHECK CONSTRAINT [FK_RestraintEvent_Student_StudentUSI]
GO
ALTER TABLE [edfi].[RestraintEventProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_RestraintEventProgram_Program] FOREIGN KEY([EducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
GO
ALTER TABLE [edfi].[RestraintEventProgram] CHECK CONSTRAINT [FK_RestraintEventProgram_Program]
GO
ALTER TABLE [edfi].[RestraintEventProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_RestraintEventProgram_RestraintEvent_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolId], [RestraintEventIdentifier], [EventDate])
REFERENCES [edfi].[RestraintEvent] ([StudentUSI], [SchoolId], [RestraintEventIdentifier], [EventDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[RestraintEventProgram] CHECK CONSTRAINT [FK_RestraintEventProgram_RestraintEvent_StudentUSI]
GO
ALTER TABLE [edfi].[RestraintEventReason]  WITH NOCHECK ADD  CONSTRAINT [FK_RestraintEventReason_RestraintEvent_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolId], [RestraintEventIdentifier], [EventDate])
REFERENCES [edfi].[RestraintEvent] ([StudentUSI], [SchoolId], [RestraintEventIdentifier], [EventDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[RestraintEventReason] CHECK CONSTRAINT [FK_RestraintEventReason_RestraintEvent_StudentUSI]
GO
ALTER TABLE [edfi].[RestraintEventReason]  WITH NOCHECK ADD  CONSTRAINT [FK_RestraintEventReason_RestraintEventReasonType_RestraintEventReasonTypeId] FOREIGN KEY([RestraintEventReasonTypeId])
REFERENCES [edfi].[RestraintEventReasonType] ([RestraintEventReasonTypeId])
GO
ALTER TABLE [edfi].[RestraintEventReason] CHECK CONSTRAINT [FK_RestraintEventReason_RestraintEventReasonType_RestraintEventReasonTypeId]
GO
ALTER TABLE [edfi].[School]  WITH NOCHECK ADD  CONSTRAINT [FK_School_AdministrativeFundingControlDescriptor_AdministrativeFundingControlDescriptorId] FOREIGN KEY([AdministrativeFundingControlDescriptorId])
REFERENCES [edfi].[AdministrativeFundingControlDescriptor] ([AdministrativeFundingControlDescriptorId])
GO
ALTER TABLE [edfi].[School] CHECK CONSTRAINT [FK_School_AdministrativeFundingControlDescriptor_AdministrativeFundingControlDescriptorId]
GO
ALTER TABLE [edfi].[School]  WITH NOCHECK ADD  CONSTRAINT [FK_School_CharterStatusType_CharterStatusTypeId] FOREIGN KEY([CharterStatusTypeId])
REFERENCES [edfi].[CharterStatusType] ([CharterStatusTypeId])
GO
ALTER TABLE [edfi].[School] CHECK CONSTRAINT [FK_School_CharterStatusType_CharterStatusTypeId]
GO
ALTER TABLE [edfi].[School]  WITH NOCHECK ADD  CONSTRAINT [FK_School_EducationOrganization_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[School] CHECK CONSTRAINT [FK_School_EducationOrganization_SchoolId]
GO
ALTER TABLE [edfi].[School]  WITH NOCHECK ADD  CONSTRAINT [FK_School_InternetAccessType_InternetAccessTypeId] FOREIGN KEY([InternetAccessTypeId])
REFERENCES [edfi].[InternetAccessType] ([InternetAccessTypeId])
GO
ALTER TABLE [edfi].[School] CHECK CONSTRAINT [FK_School_InternetAccessType_InternetAccessTypeId]
GO
ALTER TABLE [edfi].[School]  WITH NOCHECK ADD  CONSTRAINT [FK_School_LocalEducationAgency_LocalEducationAgencyId] FOREIGN KEY([LocalEducationAgencyId])
REFERENCES [edfi].[LocalEducationAgency] ([LocalEducationAgencyId])
GO
ALTER TABLE [edfi].[School] CHECK CONSTRAINT [FK_School_LocalEducationAgency_LocalEducationAgencyId]
GO
ALTER TABLE [edfi].[School]  WITH NOCHECK ADD  CONSTRAINT [FK_School_MagnetSpecialProgramEmphasisSchoolType_MagnetSpecialProgramEmphasisSchoolTypeId] FOREIGN KEY([MagnetSpecialProgramEmphasisSchoolTypeId])
REFERENCES [edfi].[MagnetSpecialProgramEmphasisSchoolType] ([MagnetSpecialProgramEmphasisSchoolTypeId])
GO
ALTER TABLE [edfi].[School] CHECK CONSTRAINT [FK_School_MagnetSpecialProgramEmphasisSchoolType_MagnetSpecialProgramEmphasisSchoolTypeId]
GO
ALTER TABLE [edfi].[School]  WITH NOCHECK ADD  CONSTRAINT [FK_School_SchoolType_SchoolTypeId] FOREIGN KEY([SchoolTypeId])
REFERENCES [edfi].[SchoolType] ([SchoolTypeId])
GO
ALTER TABLE [edfi].[School] CHECK CONSTRAINT [FK_School_SchoolType_SchoolTypeId]
GO
ALTER TABLE [edfi].[School]  WITH NOCHECK ADD  CONSTRAINT [FK_School_TitleIPartASchoolDesignationType_TitleIPartASchoolDesignationTypeId] FOREIGN KEY([TitleIPartASchoolDesignationTypeId])
REFERENCES [edfi].[TitleIPartASchoolDesignationType] ([TitleIPartASchoolDesignationTypeId])
GO
ALTER TABLE [edfi].[School] CHECK CONSTRAINT [FK_School_TitleIPartASchoolDesignationType_TitleIPartASchoolDesignationTypeId]
GO
ALTER TABLE [edfi].[SchoolCategory]  WITH NOCHECK ADD  CONSTRAINT [FK_SchoolCategory_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SchoolCategory] CHECK CONSTRAINT [FK_SchoolCategory_School_SchoolId]
GO
ALTER TABLE [edfi].[SchoolCategory]  WITH NOCHECK ADD  CONSTRAINT [FK_SchoolCategory_SchoolCategoryType_SchoolCategoryTypeId] FOREIGN KEY([SchoolCategoryTypeId])
REFERENCES [edfi].[SchoolCategoryType] ([SchoolCategoryTypeId])
GO
ALTER TABLE [edfi].[SchoolCategory] CHECK CONSTRAINT [FK_SchoolCategory_SchoolCategoryType_SchoolCategoryTypeId]
GO
ALTER TABLE [edfi].[SchoolFoodServicesEligibilityDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_SchoolFoodServicesEligibilityDescriptor_Descriptor_DescriptorId] FOREIGN KEY([SchoolFoodServicesEligibilityDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SchoolFoodServicesEligibilityDescriptor] CHECK CONSTRAINT [FK_SchoolFoodServicesEligibilityDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[SchoolFoodServicesEligibilityDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_SchoolFoodServicesEligibilityDescriptor_SchoolFoodServicesEligibilityType_SchoolFoodServicesEligibilityTypeId] FOREIGN KEY([SchoolFoodServicesEligibilityTypeId])
REFERENCES [edfi].[SchoolFoodServicesEligibilityType] ([SchoolFoodServicesEligibilityTypeId])
GO
ALTER TABLE [edfi].[SchoolFoodServicesEligibilityDescriptor] CHECK CONSTRAINT [FK_SchoolFoodServicesEligibilityDescriptor_SchoolFoodServicesEligibilityType_SchoolFoodServicesEligibilityTypeId]
GO
ALTER TABLE [edfi].[SchoolGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_SchoolGradeLevel_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[SchoolGradeLevel] CHECK CONSTRAINT [FK_SchoolGradeLevel_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[SchoolGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_SchoolGradeLevel_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SchoolGradeLevel] CHECK CONSTRAINT [FK_SchoolGradeLevel_School_SchoolId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_ClassPeriod_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName])
REFERENCES [edfi].[ClassPeriod] ([SchoolId], [ClassPeriodName])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_ClassPeriod_SchoolId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_CourseOffering_SchoolId] FOREIGN KEY([SchoolId], [TermTypeId], [SchoolYear], [LocalCourseCode])
REFERENCES [edfi].[CourseOffering] ([SchoolId], [TermTypeId], [SchoolYear], [LocalCourseCode])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_CourseOffering_SchoolId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_CreditType_AvailableCreditTypeId] FOREIGN KEY([AvailableCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_CreditType_AvailableCreditTypeId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_EducationalEnvironmentType_EducationalEnvironmentTypeId] FOREIGN KEY([EducationalEnvironmentTypeId])
REFERENCES [edfi].[EducationalEnvironmentType] ([EducationalEnvironmentTypeId])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_EducationalEnvironmentType_EducationalEnvironmentTypeId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_LanguageDescriptor_InstructionLanguageDescriptorId] FOREIGN KEY([InstructionLanguageDescriptorId])
REFERENCES [edfi].[LanguageDescriptor] ([LanguageDescriptorId])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_LanguageDescriptor_InstructionLanguageDescriptorId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_Location_SchoolId] FOREIGN KEY([SchoolId], [ClassroomIdentificationCode])
REFERENCES [edfi].[Location] ([SchoolId], [ClassroomIdentificationCode])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_Location_SchoolId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_MediumOfInstructionType_MediumOfInstructionTypeId] FOREIGN KEY([MediumOfInstructionTypeId])
REFERENCES [edfi].[MediumOfInstructionType] ([MediumOfInstructionTypeId])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_MediumOfInstructionType_MediumOfInstructionTypeId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_PopulationServedType_PopulationServedTypeId] FOREIGN KEY([PopulationServedTypeId])
REFERENCES [edfi].[PopulationServedType] ([PopulationServedTypeId])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_PopulationServedType_PopulationServedTypeId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_School_SchoolId]
GO
ALTER TABLE [edfi].[Section]  WITH NOCHECK ADD  CONSTRAINT [FK_Section_Session_SchoolId] FOREIGN KEY([SchoolId], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Session] ([SchoolId], [TermTypeId], [SchoolYear])
GO
ALTER TABLE [edfi].[Section] CHECK CONSTRAINT [FK_Section_Session_SchoolId]
GO
ALTER TABLE [edfi].[SectionAttendanceTakenEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_SectionAttendanceTakenEvent_CalendarDate] FOREIGN KEY([SchoolId], [Date])
REFERENCES [edfi].[CalendarDate] ([EducationOrganizationId], [Date])
GO
ALTER TABLE [edfi].[SectionAttendanceTakenEvent] CHECK CONSTRAINT [FK_SectionAttendanceTakenEvent_CalendarDate]
GO
ALTER TABLE [edfi].[SectionAttendanceTakenEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_SectionAttendanceTakenEvent_Section] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Section] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[SectionAttendanceTakenEvent] CHECK CONSTRAINT [FK_SectionAttendanceTakenEvent_Section]
GO
ALTER TABLE [edfi].[SectionAttendanceTakenEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_SectionAttendanceTakenEvent_Staff] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[SectionAttendanceTakenEvent] CHECK CONSTRAINT [FK_SectionAttendanceTakenEvent_Staff]
GO
ALTER TABLE [edfi].[SectionCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_SectionCharacteristic_Section_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Section] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SectionCharacteristic] CHECK CONSTRAINT [FK_SectionCharacteristic_Section_SchoolId]
GO
ALTER TABLE [edfi].[SectionCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_SectionCharacteristic_SectionCharacteristicsDescriptor_SectionCharacteristicsDescriptorId] FOREIGN KEY([SectionCharacteristicDescriptorId])
REFERENCES [edfi].[SectionCharacteristicDescriptor] ([SectionCharacteristicDescriptorId])
GO
ALTER TABLE [edfi].[SectionCharacteristic] CHECK CONSTRAINT [FK_SectionCharacteristic_SectionCharacteristicsDescriptor_SectionCharacteristicsDescriptorId]
GO
ALTER TABLE [edfi].[SectionCharacteristicDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_SectionCharacteristicDescriptor_Descriptor_DescriptorId] FOREIGN KEY([SectionCharacteristicDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SectionCharacteristicDescriptor] CHECK CONSTRAINT [FK_SectionCharacteristicDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[SectionCharacteristicDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_SectionCharacteristicDescriptor_SectionCharacteristicType_SectionCharacteristicTypeId] FOREIGN KEY([SectionCharacteristicTypeId])
REFERENCES [edfi].[SectionCharacteristicType] ([SectionCharacteristicTypeId])
GO
ALTER TABLE [edfi].[SectionCharacteristicDescriptor] CHECK CONSTRAINT [FK_SectionCharacteristicDescriptor_SectionCharacteristicType_SectionCharacteristicTypeId]
GO
ALTER TABLE [edfi].[SectionProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_SectionProgram_Program] FOREIGN KEY([EducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
GO
ALTER TABLE [edfi].[SectionProgram] CHECK CONSTRAINT [FK_SectionProgram_Program]
GO
ALTER TABLE [edfi].[SectionProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_SectionProgram_Section_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Section] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SectionProgram] CHECK CONSTRAINT [FK_SectionProgram_Section_SchoolId]
GO
ALTER TABLE [edfi].[SeparationReasonDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_SeparationReasonDescriptor_Descriptor_DescriptorId] FOREIGN KEY([SeparationReasonDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SeparationReasonDescriptor] CHECK CONSTRAINT [FK_SeparationReasonDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[SeparationReasonDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_SeparationReasonDescriptor_SeparationReasonType_SeparationReasonTypeId] FOREIGN KEY([SeparationReasonTypeId])
REFERENCES [edfi].[SeparationReasonType] ([SeparationReasonTypeId])
GO
ALTER TABLE [edfi].[SeparationReasonDescriptor] CHECK CONSTRAINT [FK_SeparationReasonDescriptor_SeparationReasonType_SeparationReasonTypeId]
GO
ALTER TABLE [edfi].[ServiceDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_ServiceDescriptor_Descriptor_DescriptorId] FOREIGN KEY([ServiceDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[ServiceDescriptor] CHECK CONSTRAINT [FK_ServiceDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[Session]  WITH NOCHECK ADD  CONSTRAINT [FK_Session_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[Session] CHECK CONSTRAINT [FK_Session_School_SchoolId]
GO
ALTER TABLE [edfi].[Session]  WITH NOCHECK ADD  CONSTRAINT [FK_Session_SchoolYearType_SchoolYear] FOREIGN KEY([SchoolYear])
REFERENCES [edfi].[SchoolYearType] ([SchoolYear])
GO
ALTER TABLE [edfi].[Session] CHECK CONSTRAINT [FK_Session_SchoolYearType_SchoolYear]
GO
ALTER TABLE [edfi].[Session]  WITH NOCHECK ADD  CONSTRAINT [FK_Session_TermType_TermTypeId] FOREIGN KEY([TermTypeId])
REFERENCES [edfi].[TermType] ([TermTypeId])
GO
ALTER TABLE [edfi].[Session] CHECK CONSTRAINT [FK_Session_TermType_TermTypeId]
GO
ALTER TABLE [edfi].[SessionAcademicWeek]  WITH NOCHECK ADD  CONSTRAINT [FK_SessionAcademicWeek_AcademicWeek] FOREIGN KEY([WeekIdentifier], [EducationOrganizationId])
REFERENCES [edfi].[AcademicWeek] ([WeekIdentifier], [EducationOrganizationId])
GO
ALTER TABLE [edfi].[SessionAcademicWeek] CHECK CONSTRAINT [FK_SessionAcademicWeek_AcademicWeek]
GO
ALTER TABLE [edfi].[SessionAcademicWeek]  WITH NOCHECK ADD  CONSTRAINT [FK_SessionAcademicWeek_Session] FOREIGN KEY([SchoolId], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Session] ([SchoolId], [TermTypeId], [SchoolYear])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SessionAcademicWeek] CHECK CONSTRAINT [FK_SessionAcademicWeek_Session]
GO
ALTER TABLE [edfi].[SessionGradingPeriod]  WITH NOCHECK ADD  CONSTRAINT [FK_SessionGradingPeriod_GradingPeriod_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [GradingPeriodDescriptorId], [BeginDate])
REFERENCES [edfi].[GradingPeriod] ([EducationOrganizationId], [GradingPeriodDescriptorId], [BeginDate])
GO
ALTER TABLE [edfi].[SessionGradingPeriod] CHECK CONSTRAINT [FK_SessionGradingPeriod_GradingPeriod_EducationOrganizationId]
GO
ALTER TABLE [edfi].[SessionGradingPeriod]  WITH NOCHECK ADD  CONSTRAINT [FK_SessionGradingPeriod_Session_EducationOrganizationId] FOREIGN KEY([SchoolId], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Session] ([SchoolId], [TermTypeId], [SchoolYear])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SessionGradingPeriod] CHECK CONSTRAINT [FK_SessionGradingPeriod_Session_EducationOrganizationId]
GO
ALTER TABLE [edfi].[SpecialEducationSettingDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_SpecialEducationSettingDescriptor_Descriptor_DescriptorId] FOREIGN KEY([SpecialEducationSettingDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[SpecialEducationSettingDescriptor] CHECK CONSTRAINT [FK_SpecialEducationSettingDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[SpecialEducationSettingDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_SpecialEducationSettingDescriptor_SpecialEducationSettingType_SpecialEducationSettingTypeId] FOREIGN KEY([SpecialEducationSettingTypeId])
REFERENCES [edfi].[SpecialEducationSettingType] ([SpecialEducationSettingTypeId])
GO
ALTER TABLE [edfi].[SpecialEducationSettingDescriptor] CHECK CONSTRAINT [FK_SpecialEducationSettingDescriptor_SpecialEducationSettingType_SpecialEducationSettingTypeId]
GO
ALTER TABLE [edfi].[Staff]  WITH NOCHECK ADD  CONSTRAINT [FK_Staff_CitizenshipStatusType_CitizenshipStatusTypeId] FOREIGN KEY([CitizenshipStatusTypeId])
REFERENCES [edfi].[CitizenshipStatusType] ([CitizenshipStatusTypeId])
GO
ALTER TABLE [edfi].[Staff] CHECK CONSTRAINT [FK_Staff_CitizenshipStatusType_CitizenshipStatusTypeId]
GO
ALTER TABLE [edfi].[Staff]  WITH NOCHECK ADD  CONSTRAINT [FK_Staff_LevelOfEducationDescriptor_HighestCompletedLevelOfEducationDescriptorId] FOREIGN KEY([HighestCompletedLevelOfEducationDescriptorId])
REFERENCES [edfi].[LevelOfEducationDescriptor] ([LevelOfEducationDescriptorId])
GO
ALTER TABLE [edfi].[Staff] CHECK CONSTRAINT [FK_Staff_LevelOfEducationDescriptor_HighestCompletedLevelOfEducationDescriptorId]
GO
ALTER TABLE [edfi].[Staff]  WITH NOCHECK ADD  CONSTRAINT [FK_Staff_OldEthnicityType_OldEthnicityTypeId] FOREIGN KEY([OldEthnicityTypeId])
REFERENCES [edfi].[OldEthnicityType] ([OldEthnicityTypeId])
GO
ALTER TABLE [edfi].[Staff] CHECK CONSTRAINT [FK_Staff_OldEthnicityType_OldEthnicityTypeId]
GO
ALTER TABLE [edfi].[Staff]  WITH NOCHECK ADD  CONSTRAINT [FK_Staff_SexType_SexTypeId] FOREIGN KEY([SexTypeId])
REFERENCES [edfi].[SexType] ([SexTypeId])
GO
ALTER TABLE [edfi].[Staff] CHECK CONSTRAINT [FK_Staff_SexType_SexTypeId]
GO
ALTER TABLE [edfi].[StaffAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffAddress_AddressType_AddressTypeId] FOREIGN KEY([AddressTypeId])
REFERENCES [edfi].[AddressType] ([AddressTypeId])
GO
ALTER TABLE [edfi].[StaffAddress] CHECK CONSTRAINT [FK_StaffAddress_AddressType_AddressTypeId]
GO
ALTER TABLE [edfi].[StaffAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffAddress_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffAddress] CHECK CONSTRAINT [FK_StaffAddress_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffAddress_StateAbbreviationType_StateAbbreviationTypeId] FOREIGN KEY([StateAbbreviationTypeId])
REFERENCES [edfi].[StateAbbreviationType] ([StateAbbreviationTypeId])
GO
ALTER TABLE [edfi].[StaffAddress] CHECK CONSTRAINT [FK_StaffAddress_StateAbbreviationType_StateAbbreviationTypeId]
GO
ALTER TABLE [edfi].[StaffClassificationDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffClassificationDescriptor_Descriptor_DescriptorId] FOREIGN KEY([StaffClassificationDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffClassificationDescriptor] CHECK CONSTRAINT [FK_StaffClassificationDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[StaffClassificationDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffClassificationDescriptor_StaffClassificationType_StaffClassificationTypeId] FOREIGN KEY([StaffClassificationTypeId])
REFERENCES [edfi].[StaffClassificationType] ([StaffClassificationTypeId])
GO
ALTER TABLE [edfi].[StaffClassificationDescriptor] CHECK CONSTRAINT [FK_StaffClassificationDescriptor_StaffClassificationType_StaffClassificationTypeId]
GO
ALTER TABLE [edfi].[StaffCohortAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffCohortAssociation_Cohort_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CohortIdentifier])
REFERENCES [edfi].[Cohort] ([EducationOrganizationId], [CohortIdentifier])
GO
ALTER TABLE [edfi].[StaffCohortAssociation] CHECK CONSTRAINT [FK_StaffCohortAssociation_Cohort_EducationOrganizationId]
GO
ALTER TABLE [edfi].[StaffCohortAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffCohortAssociation_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[StaffCohortAssociation] CHECK CONSTRAINT [FK_StaffCohortAssociation_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffCredential]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffCredential_CredentialFieldDescriptor_CredentialFieldDescriptorId] FOREIGN KEY([CredentialFieldDescriptorId])
REFERENCES [edfi].[CredentialFieldDescriptor] ([CredentialFieldDescriptorId])
GO
ALTER TABLE [edfi].[StaffCredential] CHECK CONSTRAINT [FK_StaffCredential_CredentialFieldDescriptor_CredentialFieldDescriptorId]
GO
ALTER TABLE [edfi].[StaffCredential]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffCredential_CredentialType_CredentialTypeId] FOREIGN KEY([CredentialTypeId])
REFERENCES [edfi].[CredentialType] ([CredentialTypeId])
GO
ALTER TABLE [edfi].[StaffCredential] CHECK CONSTRAINT [FK_StaffCredential_CredentialType_CredentialTypeId]
GO
ALTER TABLE [edfi].[StaffCredential]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffCredential_LevelDescriptor_LevelDescriptorId] FOREIGN KEY([LevelDescriptorId])
REFERENCES [edfi].[LevelDescriptor] ([LevelDescriptorId])
GO
ALTER TABLE [edfi].[StaffCredential] CHECK CONSTRAINT [FK_StaffCredential_LevelDescriptor_LevelDescriptorId]
GO
ALTER TABLE [edfi].[StaffCredential]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffCredential_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffCredential] CHECK CONSTRAINT [FK_StaffCredential_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffCredential]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffCredential_StateAbbreviationType_StateOfIssueAbbreviationTypeId] FOREIGN KEY([StateOfIssueStateAbbreviationTypeId])
REFERENCES [edfi].[StateAbbreviationType] ([StateAbbreviationTypeId])
GO
ALTER TABLE [edfi].[StaffCredential] CHECK CONSTRAINT [FK_StaffCredential_StateAbbreviationType_StateOfIssueAbbreviationTypeId]
GO
ALTER TABLE [edfi].[StaffCredential]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffCredential_TeachingCredentialBasisType_TeachingCredentialBasisTypeId] FOREIGN KEY([TeachingCredentialBasisTypeId])
REFERENCES [edfi].[TeachingCredentialBasisType] ([TeachingCredentialBasisTypeId])
GO
ALTER TABLE [edfi].[StaffCredential] CHECK CONSTRAINT [FK_StaffCredential_TeachingCredentialBasisType_TeachingCredentialBasisTypeId]
GO
ALTER TABLE [edfi].[StaffCredential]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffCredential_TeachingCredentialDescriptor_TeachingCredentialDescriptorId] FOREIGN KEY([TeachingCredentialDescriptorId])
REFERENCES [edfi].[TeachingCredentialDescriptor] ([TeachingCredentialDescriptorId])
GO
ALTER TABLE [edfi].[StaffCredential] CHECK CONSTRAINT [FK_StaffCredential_TeachingCredentialDescriptor_TeachingCredentialDescriptorId]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffEducationOrganizationAssignmentAssociation_StaffClassificationDescriptorId] FOREIGN KEY([StaffClassificationDescriptorId])
REFERENCES [edfi].[StaffClassificationDescriptor] ([StaffClassificationDescriptorId])
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation] CHECK CONSTRAINT [FK_StaffEducationOrganizationAssignmentAssociation_StaffClassificationDescriptorId]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffEducationOrganizationAssignmentAssociation_StaffEducationOrganizationEmploymentAssociation_StaffUSI] FOREIGN KEY([StaffUSI], [EmploymentEducationOrganizationId], [EmploymentStatusDescriptorId], [EmploymentHireDate])
REFERENCES [edfi].[StaffEducationOrganizationEmploymentAssociation] ([StaffUSI], [EducationOrganizationId], [EmploymentStatusDescriptorId], [HireDate])
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation] CHECK CONSTRAINT [FK_StaffEducationOrganizationAssignmentAssociation_StaffEducationOrganizationEmploymentAssociation_StaffUSI]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffEducationOrgAssignmentAssociation_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation] CHECK CONSTRAINT [FK_StaffEducationOrgAssignmentAssociation_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffEducationOrgAssignmentAssociation_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[StaffEducationOrganizationAssignmentAssociation] CHECK CONSTRAINT [FK_StaffEducationOrgAssignmentAssociation_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation] CHECK CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_EmploymentStatusDescriptor_EmploymentStatusDescriptorId] FOREIGN KEY([EmploymentStatusDescriptorId])
REFERENCES [edfi].[EmploymentStatusDescriptor] ([EmploymentStatusDescriptorId])
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation] CHECK CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_EmploymentStatusDescriptor_EmploymentStatusDescriptorId]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_SeparationReasonDescriptor_SeparationReasonDescriptorId] FOREIGN KEY([SeparationReasonDescriptorId])
REFERENCES [edfi].[SeparationReasonDescriptor] ([SeparationReasonDescriptorId])
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation] CHECK CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_SeparationReasonDescriptor_SeparationReasonDescriptorId]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_SeparationType_SeparationTypeId] FOREIGN KEY([SeparationTypeId])
REFERENCES [edfi].[SeparationType] ([SeparationTypeId])
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation] CHECK CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_SeparationType_SeparationTypeId]
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[StaffEducationOrganizationEmploymentAssociation] CHECK CONSTRAINT [FK_StaffEducationOrganizationEmploymentAssociation_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffElectronicMail]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffElectronicMail_ElectronicMailType_ElectronicMailTypeId] FOREIGN KEY([ElectronicMailTypeId])
REFERENCES [edfi].[ElectronicMailType] ([ElectronicMailTypeId])
GO
ALTER TABLE [edfi].[StaffElectronicMail] CHECK CONSTRAINT [FK_StaffElectronicMail_ElectronicMailType_ElectronicMailTypeId]
GO
ALTER TABLE [edfi].[StaffElectronicMail]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffElectronicMail_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffElectronicMail] CHECK CONSTRAINT [FK_StaffElectronicMail_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffIdentificationCode_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffIdentificationCode] CHECK CONSTRAINT [FK_StaffIdentificationCode_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffIdentificationCode_StaffIdentificationSystemType_StaffIdentificationSystemTypeId] FOREIGN KEY([StaffIdentificationSystemTypeId])
REFERENCES [edfi].[StaffIdentificationSystemType] ([StaffIdentificationSystemTypeId])
GO
ALTER TABLE [edfi].[StaffIdentificationCode] CHECK CONSTRAINT [FK_StaffIdentificationCode_StaffIdentificationSystemType_StaffIdentificationSystemTypeId]
GO
ALTER TABLE [edfi].[StaffIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffIdentificationDocument_CountryType_IssuerCountryTypeId] FOREIGN KEY([IssuerCountryTypeId])
REFERENCES [edfi].[CountryType] ([CountryTypeId])
GO
ALTER TABLE [edfi].[StaffIdentificationDocument] CHECK CONSTRAINT [FK_StaffIdentificationDocument_CountryType_IssuerCountryTypeId]
GO
ALTER TABLE [edfi].[StaffIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffIdentificationDocument_IdentificationDocumentUseType_IdentificationDocumentUseTypeId] FOREIGN KEY([IdentificationDocumentUseTypeId])
REFERENCES [edfi].[IdentificationDocumentUseType] ([IdentificationDocumentUseTypeId])
GO
ALTER TABLE [edfi].[StaffIdentificationDocument] CHECK CONSTRAINT [FK_StaffIdentificationDocument_IdentificationDocumentUseType_IdentificationDocumentUseTypeId]
GO
ALTER TABLE [edfi].[StaffIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffIdentificationDocument_PersonalInformationVerificationType_PersonalInformationVerificationTypeId] FOREIGN KEY([PersonalInformationVerificationTypeId])
REFERENCES [edfi].[PersonalInformationVerificationType] ([PersonalInformationVerificationTypeId])
GO
ALTER TABLE [edfi].[StaffIdentificationDocument] CHECK CONSTRAINT [FK_StaffIdentificationDocument_PersonalInformationVerificationType_PersonalInformationVerificationTypeId]
GO
ALTER TABLE [edfi].[StaffIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffIdentificationDocument_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffIdentificationDocument] CHECK CONSTRAINT [FK_StaffIdentificationDocument_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffInternationalAddress_AddressType_AddressTypeId] FOREIGN KEY([AddressTypeId])
REFERENCES [edfi].[AddressType] ([AddressTypeId])
GO
ALTER TABLE [edfi].[StaffInternationalAddress] CHECK CONSTRAINT [FK_StaffInternationalAddress_AddressType_AddressTypeId]
GO
ALTER TABLE [edfi].[StaffInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffInternationalAddress_CountryType_CountryTypeId] FOREIGN KEY([CountryTypeId])
REFERENCES [edfi].[CountryType] ([CountryTypeId])
GO
ALTER TABLE [edfi].[StaffInternationalAddress] CHECK CONSTRAINT [FK_StaffInternationalAddress_CountryType_CountryTypeId]
GO
ALTER TABLE [edfi].[StaffInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffInternationalAddress_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffInternationalAddress] CHECK CONSTRAINT [FK_StaffInternationalAddress_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffLanguages_LanguageDescriptor_LanguageDescriptorId] FOREIGN KEY([LanguageDescriptorId])
REFERENCES [edfi].[LanguageDescriptor] ([LanguageDescriptorId])
GO
ALTER TABLE [edfi].[StaffLanguage] CHECK CONSTRAINT [FK_StaffLanguages_LanguageDescriptor_LanguageDescriptorId]
GO
ALTER TABLE [edfi].[StaffLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffLanguages_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffLanguage] CHECK CONSTRAINT [FK_StaffLanguages_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffLanguageUse]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffLanguageUse_LanguageUseType_LanguageUseTypeId] FOREIGN KEY([LanguageUseTypeId])
REFERENCES [edfi].[LanguageUseType] ([LanguageUseTypeId])
GO
ALTER TABLE [edfi].[StaffLanguageUse] CHECK CONSTRAINT [FK_StaffLanguageUse_LanguageUseType_LanguageUseTypeId]
GO
ALTER TABLE [edfi].[StaffLanguageUse]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffLanguageUse_StaffLanguages_StaffUSI] FOREIGN KEY([StaffUSI], [LanguageDescriptorId])
REFERENCES [edfi].[StaffLanguage] ([StaffUSI], [LanguageDescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffLanguageUse] CHECK CONSTRAINT [FK_StaffLanguageUse_StaffLanguages_StaffUSI]
GO
ALTER TABLE [edfi].[StaffOtherName]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffOtherName_OtherNameType_OtherNameTypeId] FOREIGN KEY([OtherNameTypeId])
REFERENCES [edfi].[OtherNameType] ([OtherNameTypeId])
GO
ALTER TABLE [edfi].[StaffOtherName] CHECK CONSTRAINT [FK_StaffOtherName_OtherNameType_OtherNameTypeId]
GO
ALTER TABLE [edfi].[StaffOtherName]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffOtherName_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffOtherName] CHECK CONSTRAINT [FK_StaffOtherName_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffProgramAssociation_Program_ProgramEducationOrganizationId] FOREIGN KEY([ProgramEducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
GO
ALTER TABLE [edfi].[StaffProgramAssociation] CHECK CONSTRAINT [FK_StaffProgramAssociation_Program_ProgramEducationOrganizationId]
GO
ALTER TABLE [edfi].[StaffProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffProgramAssociation_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[StaffProgramAssociation] CHECK CONSTRAINT [FK_StaffProgramAssociation_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffRace]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffRace_RaceType_RaceTypeId] FOREIGN KEY([RaceTypeId])
REFERENCES [edfi].[RaceType] ([RaceTypeId])
GO
ALTER TABLE [edfi].[StaffRace] CHECK CONSTRAINT [FK_StaffRace_RaceType_RaceTypeId]
GO
ALTER TABLE [edfi].[StaffRace]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffRace_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffRace] CHECK CONSTRAINT [FK_StaffRace_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSchoolAssociation_ProgramAssignmentDescriptorId] FOREIGN KEY([ProgramAssignmentDescriptorId])
REFERENCES [edfi].[ProgramAssignmentDescriptor] ([ProgramAssignmentDescriptorId])
GO
ALTER TABLE [edfi].[StaffSchoolAssociation] CHECK CONSTRAINT [FK_StaffSchoolAssociation_ProgramAssignmentDescriptorId]
GO
ALTER TABLE [edfi].[StaffSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSchoolAssociation_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[StaffSchoolAssociation] CHECK CONSTRAINT [FK_StaffSchoolAssociation_School_SchoolId]
GO
ALTER TABLE [edfi].[StaffSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSchoolAssociation_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[StaffSchoolAssociation] CHECK CONSTRAINT [FK_StaffSchoolAssociation_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffSchoolAssociationAcademicSubject]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSchoolAssociationAcademicSubject_AcademicSubjectDescriptorId] FOREIGN KEY([AcademicSubjectDescriptorId])
REFERENCES [edfi].[AcademicSubjectDescriptor] ([AcademicSubjectDescriptorId])
GO
ALTER TABLE [edfi].[StaffSchoolAssociationAcademicSubject] CHECK CONSTRAINT [FK_StaffSchoolAssociationAcademicSubject_AcademicSubjectDescriptorId]
GO
ALTER TABLE [edfi].[StaffSchoolAssociationAcademicSubject]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSchoolAssociationAcademicSubjects_StaffSchoolAssociation_StaffUSI] FOREIGN KEY([StaffUSI], [ProgramAssignmentDescriptorId], [SchoolId])
REFERENCES [edfi].[StaffSchoolAssociation] ([StaffUSI], [ProgramAssignmentDescriptorId], [SchoolId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffSchoolAssociationAcademicSubject] CHECK CONSTRAINT [FK_StaffSchoolAssociationAcademicSubjects_StaffSchoolAssociation_StaffUSI]
GO
ALTER TABLE [edfi].[StaffSchoolAssociationGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSchoolAssociationGradeLevel_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[StaffSchoolAssociationGradeLevel] CHECK CONSTRAINT [FK_StaffSchoolAssociationGradeLevel_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[StaffSchoolAssociationGradeLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSchoolAssociationGradeLevel_StaffSchoolAssociation_StaffUSI] FOREIGN KEY([StaffUSI], [ProgramAssignmentDescriptorId], [SchoolId])
REFERENCES [edfi].[StaffSchoolAssociation] ([StaffUSI], [ProgramAssignmentDescriptorId], [SchoolId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffSchoolAssociationGradeLevel] CHECK CONSTRAINT [FK_StaffSchoolAssociationGradeLevel_StaffSchoolAssociation_StaffUSI]
GO
ALTER TABLE [edfi].[StaffSectionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSectionAssociation_ClassroomPositionDescriptor_ClassroomPositionDescriptorId] FOREIGN KEY([ClassroomPositionDescriptorId])
REFERENCES [edfi].[ClassroomPositionDescriptor] ([ClassroomPositionDescriptorId])
GO
ALTER TABLE [edfi].[StaffSectionAssociation] CHECK CONSTRAINT [FK_StaffSectionAssociation_ClassroomPositionDescriptor_ClassroomPositionDescriptorId]
GO
ALTER TABLE [edfi].[StaffSectionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSectionAssociation_Section_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Section] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[StaffSectionAssociation] CHECK CONSTRAINT [FK_StaffSectionAssociation_Section_SchoolId]
GO
ALTER TABLE [edfi].[StaffSectionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffSectionAssociation_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[StaffSectionAssociation] CHECK CONSTRAINT [FK_StaffSectionAssociation_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffTelephone]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffTelephone_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffTelephone] CHECK CONSTRAINT [FK_StaffTelephone_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffTelephone]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffTelephone_TelephoneNumberType_TelephoneNumberTypeId] FOREIGN KEY([TelephoneNumberTypeId])
REFERENCES [edfi].[TelephoneNumberType] ([TelephoneNumberTypeId])
GO
ALTER TABLE [edfi].[StaffTelephone] CHECK CONSTRAINT [FK_StaffTelephone_TelephoneNumberType_TelephoneNumberTypeId]
GO
ALTER TABLE [edfi].[StaffVisa]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffVisa_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StaffVisa] CHECK CONSTRAINT [FK_StaffVisa_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StaffVisa]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffVisa_VisaType_VisaTypeId] FOREIGN KEY([VisaTypeId])
REFERENCES [edfi].[VisaType] ([VisaTypeId])
GO
ALTER TABLE [edfi].[StaffVisa] CHECK CONSTRAINT [FK_StaffVisa_VisaType_VisaTypeId]
GO
ALTER TABLE [edfi].[StateEducationAgency]  WITH NOCHECK ADD  CONSTRAINT [FK_StateEducationAgency_EducationOrganization_StateEducationAgencyId] FOREIGN KEY([StateEducationAgencyId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StateEducationAgency] CHECK CONSTRAINT [FK_StateEducationAgency_EducationOrganization_StateEducationAgencyId]
GO
ALTER TABLE [edfi].[StateEducationAgencyAccountability]  WITH NOCHECK ADD  CONSTRAINT [FK_StateEducationAgencyAccountability_SchoolYearType_SchoolYear] FOREIGN KEY([SchoolYear])
REFERENCES [edfi].[SchoolYearType] ([SchoolYear])
GO
ALTER TABLE [edfi].[StateEducationAgencyAccountability] CHECK CONSTRAINT [FK_StateEducationAgencyAccountability_SchoolYearType_SchoolYear]
GO
ALTER TABLE [edfi].[StateEducationAgencyAccountability]  WITH NOCHECK ADD  CONSTRAINT [FK_StateEducationAgencyAccountability_StateEducationAgency_StateEducationAgencyId] FOREIGN KEY([StateEducationAgencyId])
REFERENCES [edfi].[StateEducationAgency] ([StateEducationAgencyId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StateEducationAgencyAccountability] CHECK CONSTRAINT [FK_StateEducationAgencyAccountability_StateEducationAgency_StateEducationAgencyId]
GO
ALTER TABLE [edfi].[StateEducationAgencyFederalFunds]  WITH NOCHECK ADD  CONSTRAINT [FK_StateEducationAgencyFederalFunds_StateEducationAgency_StateEducationAgencyId] FOREIGN KEY([StateEducationAgencyId])
REFERENCES [edfi].[StateEducationAgency] ([StateEducationAgencyId])
GO
ALTER TABLE [edfi].[StateEducationAgencyFederalFunds] CHECK CONSTRAINT [FK_StateEducationAgencyFederalFunds_StateEducationAgency_StateEducationAgencyId]
GO
ALTER TABLE [edfi].[Student]  WITH NOCHECK ADD  CONSTRAINT [FK_Student_CitizenshipStatusType_CitizenshipStatusTypeId] FOREIGN KEY([CitizenshipStatusTypeId])
REFERENCES [edfi].[CitizenshipStatusType] ([CitizenshipStatusTypeId])
GO
ALTER TABLE [edfi].[Student] CHECK CONSTRAINT [FK_Student_CitizenshipStatusType_CitizenshipStatusTypeId]
GO
ALTER TABLE [edfi].[Student]  WITH NOCHECK ADD  CONSTRAINT [FK_Student_CountryCodeType_BirthCountryCodeTypeId] FOREIGN KEY([BirthCountryCodeTypeId])
REFERENCES [edfi].[CountryCodeType] ([CountryCodeTypeId])
GO
ALTER TABLE [edfi].[Student] CHECK CONSTRAINT [FK_Student_CountryCodeType_BirthCountryCodeTypeId]
GO
ALTER TABLE [edfi].[Student]  WITH NOCHECK ADD  CONSTRAINT [FK_Student_LimitedEnglishProficiencyDescriptorId] FOREIGN KEY([LimitedEnglishProficiencyDescriptorId])
REFERENCES [edfi].[LimitedEnglishProficiencyDescriptor] ([LimitedEnglishProficiencyDescriptorId])
GO
ALTER TABLE [edfi].[Student] CHECK CONSTRAINT [FK_Student_LimitedEnglishProficiencyDescriptorId]
GO
ALTER TABLE [edfi].[Student]  WITH NOCHECK ADD  CONSTRAINT [FK_Student_OldEthnicityType_OldEthnicityTypeId] FOREIGN KEY([OldEthnicityTypeId])
REFERENCES [edfi].[OldEthnicityType] ([OldEthnicityTypeId])
GO
ALTER TABLE [edfi].[Student] CHECK CONSTRAINT [FK_Student_OldEthnicityType_OldEthnicityTypeId]
GO
ALTER TABLE [edfi].[Student]  WITH NOCHECK ADD  CONSTRAINT [FK_Student_SchoolFoodServicesEligibilityDescriptor_SchoolFoodServicesEligibilityDescriptorId] FOREIGN KEY([SchoolFoodServicesEligibilityDescriptorId])
REFERENCES [edfi].[SchoolFoodServicesEligibilityDescriptor] ([SchoolFoodServicesEligibilityDescriptorId])
GO
ALTER TABLE [edfi].[Student] CHECK CONSTRAINT [FK_Student_SchoolFoodServicesEligibilityDescriptor_SchoolFoodServicesEligibilityDescriptorId]
GO
ALTER TABLE [edfi].[Student]  WITH NOCHECK ADD  CONSTRAINT [FK_Student_SexType_SexTypeId] FOREIGN KEY([SexTypeId])
REFERENCES [edfi].[SexType] ([SexTypeId])
GO
ALTER TABLE [edfi].[Student] CHECK CONSTRAINT [FK_Student_SexType_SexTypeId]
GO
ALTER TABLE [edfi].[Student]  WITH NOCHECK ADD  CONSTRAINT [FK_Student_StateAbbreviationType_StateOfBirthAbbreviationTypeId] FOREIGN KEY([BirthStateAbbreviationTypeId])
REFERENCES [edfi].[StateAbbreviationType] ([StateAbbreviationTypeId])
GO
ALTER TABLE [edfi].[Student] CHECK CONSTRAINT [FK_Student_StateAbbreviationType_StateOfBirthAbbreviationTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecord]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecord_CreditType_CumulativeAttemptedCreditTypeId] FOREIGN KEY([CumulativeAttemptedCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[StudentAcademicRecord] CHECK CONSTRAINT [FK_StudentAcademicRecord_CreditType_CumulativeAttemptedCreditTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecord]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecord_CreditType_CumulativeEarnedCreditTypeId] FOREIGN KEY([CumulativeEarnedCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[StudentAcademicRecord] CHECK CONSTRAINT [FK_StudentAcademicRecord_CreditType_CumulativeEarnedCreditTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecord]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecord_CreditType_SessionAttemptedCreditTypeId] FOREIGN KEY([SessionAttemptedCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[StudentAcademicRecord] CHECK CONSTRAINT [FK_StudentAcademicRecord_CreditType_SessionAttemptedCreditTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecord]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecord_CreditType_SessionEarnedCreditTypeId] FOREIGN KEY([SessionEarnedCreditTypeId])
REFERENCES [edfi].[CreditType] ([CreditTypeId])
GO
ALTER TABLE [edfi].[StudentAcademicRecord] CHECK CONSTRAINT [FK_StudentAcademicRecord_CreditType_SessionEarnedCreditTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecord]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecord_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[StudentAcademicRecord] CHECK CONSTRAINT [FK_StudentAcademicRecord_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[StudentAcademicRecord]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecord_SchoolYearType_SchoolYear] FOREIGN KEY([SchoolYear])
REFERENCES [edfi].[SchoolYearType] ([SchoolYear])
GO
ALTER TABLE [edfi].[StudentAcademicRecord] CHECK CONSTRAINT [FK_StudentAcademicRecord_SchoolYearType_SchoolYear]
GO
ALTER TABLE [edfi].[StudentAcademicRecord]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecord_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentAcademicRecord] CHECK CONSTRAINT [FK_StudentAcademicRecord_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAcademicRecord]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecord_TermType_TermTypeId] FOREIGN KEY([TermTypeId])
REFERENCES [edfi].[TermType] ([TermTypeId])
GO
ALTER TABLE [edfi].[StudentAcademicRecord] CHECK CONSTRAINT [FK_StudentAcademicRecord_TermType_TermTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecordAcademicHonor]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordAcademicHonor_AcademicHonorCategoryType_AcademicHonorCategoryTypeId] FOREIGN KEY([AcademicHonorCategoryTypeId])
REFERENCES [edfi].[AcademicHonorCategoryType] ([AcademicHonorCategoryTypeId])
GO
ALTER TABLE [edfi].[StudentAcademicRecordAcademicHonor] CHECK CONSTRAINT [FK_StudentAcademicRecordAcademicHonor_AcademicHonorCategoryType_AcademicHonorCategoryTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecordAcademicHonor]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordAcademicHonor_AchievementCategoryDescriptor_AchievementCategoryDescriptorId] FOREIGN KEY([AchievementCategoryDescriptorId])
REFERENCES [edfi].[AchievementCategoryDescriptor] ([AchievementCategoryDescriptorId])
GO
ALTER TABLE [edfi].[StudentAcademicRecordAcademicHonor] CHECK CONSTRAINT [FK_StudentAcademicRecordAcademicHonor_AchievementCategoryDescriptor_AchievementCategoryDescriptorId]
GO
ALTER TABLE [edfi].[StudentAcademicRecordAcademicHonor]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordAcademicHonor_StudentAcademicRecord_StudentUSI] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
REFERENCES [edfi].[StudentAcademicRecord] ([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAcademicRecordAcademicHonor] CHECK CONSTRAINT [FK_StudentAcademicRecordAcademicHonor_StudentAcademicRecord_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAcademicRecordClassRanking]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordClassRanking_StudentAcademicRecord_StudentUSI] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
REFERENCES [edfi].[StudentAcademicRecord] ([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAcademicRecordClassRanking] CHECK CONSTRAINT [FK_StudentAcademicRecordClassRanking_StudentAcademicRecord_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAcademicRecordDiploma]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordDiploma_AchievementCategoryDescriptor_AchievementCategoryDescriptorId] FOREIGN KEY([AchievementCategoryDescriptorId])
REFERENCES [edfi].[AchievementCategoryDescriptor] ([AchievementCategoryDescriptorId])
GO
ALTER TABLE [edfi].[StudentAcademicRecordDiploma] CHECK CONSTRAINT [FK_StudentAcademicRecordDiploma_AchievementCategoryDescriptor_AchievementCategoryDescriptorId]
GO
ALTER TABLE [edfi].[StudentAcademicRecordDiploma]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordDiploma_DiplomaLevelType_DiplomaLevelTypeId] FOREIGN KEY([DiplomaLevelTypeId])
REFERENCES [edfi].[DiplomaLevelType] ([DiplomaLevelTypeId])
GO
ALTER TABLE [edfi].[StudentAcademicRecordDiploma] CHECK CONSTRAINT [FK_StudentAcademicRecordDiploma_DiplomaLevelType_DiplomaLevelTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecordDiploma]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordDiploma_DiplomaType_DiplomaTypeId] FOREIGN KEY([DiplomaTypeId])
REFERENCES [edfi].[DiplomaType] ([DiplomaTypeId])
GO
ALTER TABLE [edfi].[StudentAcademicRecordDiploma] CHECK CONSTRAINT [FK_StudentAcademicRecordDiploma_DiplomaType_DiplomaTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecordDiploma]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordDiploma_StudentAcademicRecord_StudentUSI] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
REFERENCES [edfi].[StudentAcademicRecord] ([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAcademicRecordDiploma] CHECK CONSTRAINT [FK_StudentAcademicRecordDiploma_StudentAcademicRecord_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAcademicRecordRecognition]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordRecognition_AchievementCategoryDescriptor_AchievementCategoryDescriptorId] FOREIGN KEY([AchievementCategoryDescriptorId])
REFERENCES [edfi].[AchievementCategoryDescriptor] ([AchievementCategoryDescriptorId])
GO
ALTER TABLE [edfi].[StudentAcademicRecordRecognition] CHECK CONSTRAINT [FK_StudentAcademicRecordRecognition_AchievementCategoryDescriptor_AchievementCategoryDescriptorId]
GO
ALTER TABLE [edfi].[StudentAcademicRecordRecognition]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordRecognition_RecognitionType_RecognitionTypeId] FOREIGN KEY([RecognitionTypeId])
REFERENCES [edfi].[RecognitionType] ([RecognitionTypeId])
GO
ALTER TABLE [edfi].[StudentAcademicRecordRecognition] CHECK CONSTRAINT [FK_StudentAcademicRecordRecognition_RecognitionType_RecognitionTypeId]
GO
ALTER TABLE [edfi].[StudentAcademicRecordRecognition]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordRecognition_StudentAcademicRecord_StudentUSI] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
REFERENCES [edfi].[StudentAcademicRecord] ([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAcademicRecordRecognition] CHECK CONSTRAINT [FK_StudentAcademicRecordRecognition_StudentAcademicRecord_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAcademicRecordReportCard]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordReportCard_ReportCard] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
REFERENCES [edfi].[ReportCard] ([StudentUSI], [EducationOrganizationId], [GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
GO
ALTER TABLE [edfi].[StudentAcademicRecordReportCard] CHECK CONSTRAINT [FK_StudentAcademicRecordReportCard_ReportCard]
GO
ALTER TABLE [edfi].[StudentAcademicRecordReportCard]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAcademicRecordReportCard_StudentAcademicRecord_StudentUSI] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
REFERENCES [edfi].[StudentAcademicRecord] ([StudentUSI], [EducationOrganizationId], [SchoolYear], [TermTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAcademicRecordReportCard] CHECK CONSTRAINT [FK_StudentAcademicRecordReportCard_StudentAcademicRecord_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAddress_AddressType_AddressTypeId] FOREIGN KEY([AddressTypeId])
REFERENCES [edfi].[AddressType] ([AddressTypeId])
GO
ALTER TABLE [edfi].[StudentAddress] CHECK CONSTRAINT [FK_StudentAddress_AddressType_AddressTypeId]
GO
ALTER TABLE [edfi].[StudentAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAddress_StateAbbreviationType_StateAbbreviationTypeId] FOREIGN KEY([StateAbbreviationTypeId])
REFERENCES [edfi].[StateAbbreviationType] ([StateAbbreviationTypeId])
GO
ALTER TABLE [edfi].[StudentAddress] CHECK CONSTRAINT [FK_StudentAddress_StateAbbreviationType_StateAbbreviationTypeId]
GO
ALTER TABLE [edfi].[StudentAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAddress_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAddress] CHECK CONSTRAINT [FK_StudentAddress_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessment_AdministrationEnvironmentType_AdministrationEnvironmentTypeId] FOREIGN KEY([AdministrationEnvironmentTypeId])
REFERENCES [edfi].[AdministrationEnvironmentType] ([AdministrationEnvironmentTypeId])
GO
ALTER TABLE [edfi].[StudentAssessment] CHECK CONSTRAINT [FK_StudentAssessment_AdministrationEnvironmentType_AdministrationEnvironmentTypeId]
GO
ALTER TABLE [edfi].[StudentAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessment_Assessment_AssessmentTitle] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
REFERENCES [edfi].[Assessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version])
GO
ALTER TABLE [edfi].[StudentAssessment] CHECK CONSTRAINT [FK_StudentAssessment_Assessment_AssessmentTitle]
GO
ALTER TABLE [edfi].[StudentAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessment_EventCircumstanceType_EventCircumstanceTypeId] FOREIGN KEY([EventCircumstanceTypeId])
REFERENCES [edfi].[EventCircumstanceType] ([EventCircumstanceTypeId])
GO
ALTER TABLE [edfi].[StudentAssessment] CHECK CONSTRAINT [FK_StudentAssessment_EventCircumstanceType_EventCircumstanceTypeId]
GO
ALTER TABLE [edfi].[StudentAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessment_LanguageDescriptor_AdministrationLanguageDescriptorId] FOREIGN KEY([AdministrationLanguageDescriptorId])
REFERENCES [edfi].[LanguageDescriptor] ([LanguageDescriptorId])
GO
ALTER TABLE [edfi].[StudentAssessment] CHECK CONSTRAINT [FK_StudentAssessment_LanguageDescriptor_AdministrationLanguageDescriptorId]
GO
ALTER TABLE [edfi].[StudentAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessment_ReasonNotTestedType_ReasonNotTestedTypeId] FOREIGN KEY([ReasonNotTestedTypeId])
REFERENCES [edfi].[ReasonNotTestedType] ([ReasonNotTestedTypeId])
GO
ALTER TABLE [edfi].[StudentAssessment] CHECK CONSTRAINT [FK_StudentAssessment_ReasonNotTestedType_ReasonNotTestedTypeId]
GO
ALTER TABLE [edfi].[StudentAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessment_RetestIndicatorType_RetestIndicatorTypeId] FOREIGN KEY([RetestIndicatorTypeId])
REFERENCES [edfi].[RetestIndicatorType] ([RetestIndicatorTypeId])
GO
ALTER TABLE [edfi].[StudentAssessment] CHECK CONSTRAINT [FK_StudentAssessment_RetestIndicatorType_RetestIndicatorTypeId]
GO
ALTER TABLE [edfi].[StudentAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessment_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentAssessment] CHECK CONSTRAINT [FK_StudentAssessment_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessment_WhenAssessedGradeLevelDescriptorId] FOREIGN KEY([WhenAssessedGradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[StudentAssessment] CHECK CONSTRAINT [FK_StudentAssessment_WhenAssessedGradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[StudentAssessmentAccommodation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentAccommodation_AccommodationDescriptor_AccommodationDescriptorId] FOREIGN KEY([AccommodationDescriptorId])
REFERENCES [edfi].[AccommodationDescriptor] ([AccommodationDescriptorId])
GO
ALTER TABLE [edfi].[StudentAssessmentAccommodation] CHECK CONSTRAINT [FK_StudentAssessmentAccommodation_AccommodationDescriptor_AccommodationDescriptorId]
GO
ALTER TABLE [edfi].[StudentAssessmentAccommodation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentAccommodation_StudentAssessment_StudentUSI] FOREIGN KEY([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
REFERENCES [edfi].[StudentAssessment] ([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAssessmentAccommodation] CHECK CONSTRAINT [FK_StudentAssessmentAccommodation_StudentAssessment_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAssessmentItem]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentItem_AssessmentItem] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
REFERENCES [edfi].[AssessmentItem] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
GO
ALTER TABLE [edfi].[StudentAssessmentItem] CHECK CONSTRAINT [FK_StudentAssessmentItem_AssessmentItem]
GO
ALTER TABLE [edfi].[StudentAssessmentItem]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentItem_AssessmentItemResultType_AssessmentItemResultTypeId] FOREIGN KEY([AssessmentItemResultTypeId])
REFERENCES [edfi].[AssessmentItemResultType] ([AssessmentItemResultTypeId])
GO
ALTER TABLE [edfi].[StudentAssessmentItem] CHECK CONSTRAINT [FK_StudentAssessmentItem_AssessmentItemResultType_AssessmentItemResultTypeId]
GO
ALTER TABLE [edfi].[StudentAssessmentItem]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentItem_ResponseIndicatorType_ResponseIndicatorTypeId] FOREIGN KEY([ResponseIndicatorTypeId])
REFERENCES [edfi].[ResponseIndicatorType] ([ResponseIndicatorTypeId])
GO
ALTER TABLE [edfi].[StudentAssessmentItem] CHECK CONSTRAINT [FK_StudentAssessmentItem_ResponseIndicatorType_ResponseIndicatorTypeId]
GO
ALTER TABLE [edfi].[StudentAssessmentItem]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentItem_StudentAssessment_StudentUSI] FOREIGN KEY([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
REFERENCES [edfi].[StudentAssessment] ([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAssessmentItem] CHECK CONSTRAINT [FK_StudentAssessmentItem_StudentAssessment_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentPerformanceLevel_PerformanceLevelDescriptor_PerformanceLevelDescriptorId] FOREIGN KEY([PerformanceLevelDescriptorId])
REFERENCES [edfi].[PerformanceLevelDescriptor] ([PerformanceLevelDescriptorId])
GO
ALTER TABLE [edfi].[StudentAssessmentPerformanceLevel] CHECK CONSTRAINT [FK_StudentAssessmentPerformanceLevel_PerformanceLevelDescriptor_PerformanceLevelDescriptorId]
GO
ALTER TABLE [edfi].[StudentAssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentPerformanceLevel_StudentAssessment_StudentUSI] FOREIGN KEY([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
REFERENCES [edfi].[StudentAssessment] ([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAssessmentPerformanceLevel] CHECK CONSTRAINT [FK_StudentAssessmentPerformanceLevel_StudentAssessment_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAssessmentScoreResult]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentScoreResult_AssessmentReportingMethodType_AssessmentReportingMethodTypeId] FOREIGN KEY([AssessmentReportingMethodTypeId])
REFERENCES [edfi].[AssessmentReportingMethodType] ([AssessmentReportingMethodTypeId])
GO
ALTER TABLE [edfi].[StudentAssessmentScoreResult] CHECK CONSTRAINT [FK_StudentAssessmentScoreResult_AssessmentReportingMethodType_AssessmentReportingMethodTypeId]
GO
ALTER TABLE [edfi].[StudentAssessmentScoreResult]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentScoreResult_ResultDatatypeType_ResultDatatypeTypeId] FOREIGN KEY([ResultDatatypeTypeId])
REFERENCES [edfi].[ResultDatatypeType] ([ResultDatatypeTypeId])
GO
ALTER TABLE [edfi].[StudentAssessmentScoreResult] CHECK CONSTRAINT [FK_StudentAssessmentScoreResult_ResultDatatypeType_ResultDatatypeTypeId]
GO
ALTER TABLE [edfi].[StudentAssessmentScoreResult]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentScoreResult_StudentAssessment_StudentUSI] FOREIGN KEY([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
REFERENCES [edfi].[StudentAssessment] ([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAssessmentScoreResult] CHECK CONSTRAINT [FK_StudentAssessmentScoreResult_StudentAssessment_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessment_ObjectiveAssessment] FOREIGN KEY([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
REFERENCES [edfi].[ObjectiveAssessment] ([AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode])
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessment] CHECK CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessment_ObjectiveAssessment]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessment]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessment_StudentAssessment_StudentUSI] FOREIGN KEY([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
REFERENCES [edfi].[StudentAssessment] ([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [AdministrationDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessment] CHECK CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessment_StudentAssessment_StudentUSI]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentPerformanceLevel_PerformanceLevelDescriptor_PerformanceLevelDescriptorId] FOREIGN KEY([PerformanceLevelDescriptorId])
REFERENCES [edfi].[PerformanceLevelDescriptor] ([PerformanceLevelDescriptorId])
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentPerformanceLevel] CHECK CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentPerformanceLevel_PerformanceLevelDescriptor_PerformanceLevelDescriptorId]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentPerformanceLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentPerformanceLevel_StudentAssessmentStudentObjectiveAssessment] FOREIGN KEY([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode], [AdministrationDate])
REFERENCES [edfi].[StudentAssessmentStudentObjectiveAssessment] ([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode], [AdministrationDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentPerformanceLevel] CHECK CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentPerformanceLevel_StudentAssessmentStudentObjectiveAssessment]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentScoreResult_StudentObjectiveAssessment] FOREIGN KEY([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode], [AdministrationDate])
REFERENCES [edfi].[StudentAssessmentStudentObjectiveAssessment] ([StudentUSI], [AssessmentTitle], [AcademicSubjectDescriptorId], [AssessedGradeLevelDescriptorId], [Version], [IdentificationCode], [AdministrationDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult] CHECK CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentScoreResult_StudentObjectiveAssessment]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentScoreResults_AssessmentReportingMethodType_AssessmentReportingMethodTypeId] FOREIGN KEY([AssessmentReportingMethodTypeId])
REFERENCES [edfi].[AssessmentReportingMethodType] ([AssessmentReportingMethodTypeId])
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult] CHECK CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentScoreResults_AssessmentReportingMethodType_AssessmentReportingMethodTypeId]
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentScoreResults_ResultDatatypeType_ResultDatatypeTypeId] FOREIGN KEY([ResultDatatypeTypeId])
REFERENCES [edfi].[ResultDatatypeType] ([ResultDatatypeTypeId])
GO
ALTER TABLE [edfi].[StudentAssessmentStudentObjectiveAssessmentScoreResult] CHECK CONSTRAINT [FK_StudentAssessmentStudentObjectiveAssessmentScoreResults_ResultDatatypeType_ResultDatatypeTypeId]
GO
ALTER TABLE [edfi].[StudentCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCharacteristic_StudentCharacteristicDescriptorId] FOREIGN KEY([StudentCharacteristicDescriptorId])
REFERENCES [edfi].[StudentCharacteristicDescriptor] ([StudentCharacteristicDescriptorId])
GO
ALTER TABLE [edfi].[StudentCharacteristic] CHECK CONSTRAINT [FK_StudentCharacteristic_StudentCharacteristicDescriptorId]
GO
ALTER TABLE [edfi].[StudentCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCharacteristics_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentCharacteristic] CHECK CONSTRAINT [FK_StudentCharacteristics_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentCharacteristicDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCharacteristicDescriptor_Descriptor_DescriptorId] FOREIGN KEY([StudentCharacteristicDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentCharacteristicDescriptor] CHECK CONSTRAINT [FK_StudentCharacteristicDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[StudentCharacteristicDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCharacteristicDescriptor_StudentCharacteristicType_StudentCharacteristicTypeId] FOREIGN KEY([StudentCharacteristicTypeId])
REFERENCES [edfi].[StudentCharacteristicType] ([StudentCharacteristicTypeId])
GO
ALTER TABLE [edfi].[StudentCharacteristicDescriptor] CHECK CONSTRAINT [FK_StudentCharacteristicDescriptor_StudentCharacteristicType_StudentCharacteristicTypeId]
GO
ALTER TABLE [edfi].[StudentCohortAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCohortAssociation_Cohort_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CohortIdentifier])
REFERENCES [edfi].[Cohort] ([EducationOrganizationId], [CohortIdentifier])
GO
ALTER TABLE [edfi].[StudentCohortAssociation] CHECK CONSTRAINT [FK_StudentCohortAssociation_Cohort_EducationOrganizationId]
GO
ALTER TABLE [edfi].[StudentCohortAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCohortAssociation_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentCohortAssociation] CHECK CONSTRAINT [FK_StudentCohortAssociation_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentCohortAssociationSection]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCohortAssociationSection_Section_LocalCourseCode] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Section] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[StudentCohortAssociationSection] CHECK CONSTRAINT [FK_StudentCohortAssociationSection_Section_LocalCourseCode]
GO
ALTER TABLE [edfi].[StudentCohortAssociationSection]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCohortAssociationSection_StudentCohortAssociation_StudentUSI] FOREIGN KEY([StudentUSI], [EducationOrganizationId], [CohortIdentifier], [BeginDate])
REFERENCES [edfi].[StudentCohortAssociation] ([StudentUSI], [EducationOrganizationId], [CohortIdentifier], [BeginDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentCohortAssociationSection] CHECK CONSTRAINT [FK_StudentCohortAssociationSection_StudentCohortAssociation_StudentUSI]
GO
ALTER TABLE [edfi].[StudentCohortYear]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCohortYears_CohortYearType_CohortYearTypeId] FOREIGN KEY([CohortYearTypeId])
REFERENCES [edfi].[CohortYearType] ([CohortYearTypeId])
GO
ALTER TABLE [edfi].[StudentCohortYear] CHECK CONSTRAINT [FK_StudentCohortYears_CohortYearType_CohortYearTypeId]
GO
ALTER TABLE [edfi].[StudentCohortYear]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCohortYears_SchoolYearType_SchoolYear] FOREIGN KEY([SchoolYear])
REFERENCES [edfi].[SchoolYearType] ([SchoolYear])
GO
ALTER TABLE [edfi].[StudentCohortYear] CHECK CONSTRAINT [FK_StudentCohortYears_SchoolYearType_SchoolYear]
GO
ALTER TABLE [edfi].[StudentCohortYear]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCohortYears_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentCohortYear] CHECK CONSTRAINT [FK_StudentCohortYears_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentCompetencyObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCompetencyObjective_CompetencyLevelDescriptor_CompetencyLevelDescriptorId] FOREIGN KEY([CompetencyLevelDescriptorId])
REFERENCES [edfi].[CompetencyLevelDescriptor] ([CompetencyLevelDescriptorId])
GO
ALTER TABLE [edfi].[StudentCompetencyObjective] CHECK CONSTRAINT [FK_StudentCompetencyObjective_CompetencyLevelDescriptor_CompetencyLevelDescriptorId]
GO
ALTER TABLE [edfi].[StudentCompetencyObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCompetencyObjective_CompetencyObjective_Objective] FOREIGN KEY([Objective], [ObjectiveGradeLevelDescriptorId], [ObjectiveEducationOrganizationId])
REFERENCES [edfi].[CompetencyObjective] ([Objective], [ObjectiveGradeLevelDescriptorId], [EducationOrganizationId])
GO
ALTER TABLE [edfi].[StudentCompetencyObjective] CHECK CONSTRAINT [FK_StudentCompetencyObjective_CompetencyObjective_Objective]
GO
ALTER TABLE [edfi].[StudentCompetencyObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCompetencyObjective_GradingPeriod] FOREIGN KEY([GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
REFERENCES [edfi].[GradingPeriod] ([EducationOrganizationId], [GradingPeriodDescriptorId], [BeginDate])
GO
ALTER TABLE [edfi].[StudentCompetencyObjective] CHECK CONSTRAINT [FK_StudentCompetencyObjective_GradingPeriod]
GO
ALTER TABLE [edfi].[StudentCompetencyObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCompetencyObjective_StudentProgramAssociation] FOREIGN KEY([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
REFERENCES [edfi].[StudentProgramAssociation] ([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
GO
ALTER TABLE [edfi].[StudentCompetencyObjective] CHECK CONSTRAINT [FK_StudentCompetencyObjective_StudentProgramAssociation]
GO
ALTER TABLE [edfi].[StudentCompetencyObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCompetencyObjective_StudentSectionAssociation_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate])
REFERENCES [edfi].[StudentSectionAssociation] ([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[StudentCompetencyObjective] CHECK CONSTRAINT [FK_StudentCompetencyObjective_StudentSectionAssociation_StudentUSI]
GO
ALTER TABLE [edfi].[StudentCTEProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCTEProgramAssociation_StudentProgramAssociation] FOREIGN KEY([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
REFERENCES [edfi].[StudentProgramAssociation] ([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentCTEProgramAssociation] CHECK CONSTRAINT [FK_StudentCTEProgramAssociation_StudentProgramAssociation]
GO
ALTER TABLE [edfi].[StudentCTEProgramAssociationCTEProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCTEProgramAssociationCTEProgram_CareerPathwayType_CareerPathwayTypeId] FOREIGN KEY([CareerPathwayTypeId])
REFERENCES [edfi].[CareerPathwayType] ([CareerPathwayTypeId])
GO
ALTER TABLE [edfi].[StudentCTEProgramAssociationCTEProgram] CHECK CONSTRAINT [FK_StudentCTEProgramAssociationCTEProgram_CareerPathwayType_CareerPathwayTypeId]
GO
ALTER TABLE [edfi].[StudentCTEProgramAssociationCTEProgram]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentCTEProgramAssociationCTEProgram_StudentCTEProgramAssociation] FOREIGN KEY([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
REFERENCES [edfi].[StudentCTEProgramAssociation] ([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentCTEProgramAssociationCTEProgram] CHECK CONSTRAINT [FK_StudentCTEProgramAssociationCTEProgram_StudentCTEProgramAssociation]
GO
ALTER TABLE [edfi].[StudentDisability]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentDisability_DisabilityDescriptor_DisabilityDescriptorId] FOREIGN KEY([DisabilityDescriptorId])
REFERENCES [edfi].[DisabilityDescriptor] ([DisabilityDescriptorId])
GO
ALTER TABLE [edfi].[StudentDisability] CHECK CONSTRAINT [FK_StudentDisability_DisabilityDescriptor_DisabilityDescriptorId]
GO
ALTER TABLE [edfi].[StudentDisability]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentDisability_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentDisability] CHECK CONSTRAINT [FK_StudentDisability_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentDisciplineIncidentAssociation_DisciplineIncident_SchoolId] FOREIGN KEY([SchoolId], [IncidentIdentifier])
REFERENCES [edfi].[DisciplineIncident] ([SchoolId], [IncidentIdentifier])
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociation] CHECK CONSTRAINT [FK_StudentDisciplineIncidentAssociation_DisciplineIncident_SchoolId]
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentDisciplineIncidentAssociation_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociation] CHECK CONSTRAINT [FK_StudentDisciplineIncidentAssociation_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentDisciplineIncidentAssociation_StudentParticipationCodeType_StudentParticipationCodeTypeId] FOREIGN KEY([StudentParticipationCodeTypeId])
REFERENCES [edfi].[StudentParticipationCodeType] ([StudentParticipationCodeTypeId])
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociation] CHECK CONSTRAINT [FK_StudentDisciplineIncidentAssociation_StudentParticipationCodeType_StudentParticipationCodeTypeId]
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociationBehavior]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentDisciplineIncidentBehavior_BehaviorDescriptor_BehaviorDescriptorId] FOREIGN KEY([BehaviorDescriptorId])
REFERENCES [edfi].[BehaviorDescriptor] ([BehaviorDescriptorId])
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociationBehavior] CHECK CONSTRAINT [FK_StudentDisciplineIncidentBehavior_BehaviorDescriptor_BehaviorDescriptorId]
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociationBehavior]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentDisciplineIncidentBehavior_StudentDisciplineIncidentAssociation_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolId], [IncidentIdentifier])
REFERENCES [edfi].[StudentDisciplineIncidentAssociation] ([StudentUSI], [SchoolId], [IncidentIdentifier])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentDisciplineIncidentAssociationBehavior] CHECK CONSTRAINT [FK_StudentDisciplineIncidentBehavior_StudentDisciplineIncidentAssociation_StudentUSI]
GO
ALTER TABLE [edfi].[StudentEducationOrganizationAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentEducationOrganizationAssociation_EducationOrganization_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[StudentEducationOrganizationAssociation] CHECK CONSTRAINT [FK_StudentEducationOrganizationAssociation_EducationOrganization_EducationOrganizationId]
GO
ALTER TABLE [edfi].[StudentEducationOrganizationAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentEducationOrganizationAssociation_ResponsibilityDescriptor_ResponsibilityDescriptorId] FOREIGN KEY([ResponsibilityDescriptorId])
REFERENCES [edfi].[ResponsibilityDescriptor] ([ResponsibilityDescriptorId])
GO
ALTER TABLE [edfi].[StudentEducationOrganizationAssociation] CHECK CONSTRAINT [FK_StudentEducationOrganizationAssociation_ResponsibilityDescriptor_ResponsibilityDescriptorId]
GO
ALTER TABLE [edfi].[StudentEducationOrganizationAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentEducationOrganizationAssociation_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentEducationOrganizationAssociation] CHECK CONSTRAINT [FK_StudentEducationOrganizationAssociation_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentElectronicMail]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentElectronicMail_ElectronicMailType_ElectronicMailTypeId] FOREIGN KEY([ElectronicMailTypeId])
REFERENCES [edfi].[ElectronicMailType] ([ElectronicMailTypeId])
GO
ALTER TABLE [edfi].[StudentElectronicMail] CHECK CONSTRAINT [FK_StudentElectronicMail_ElectronicMailType_ElectronicMailTypeId]
GO
ALTER TABLE [edfi].[StudentElectronicMail]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentElectronicMail_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentElectronicMail] CHECK CONSTRAINT [FK_StudentElectronicMail_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentGradebookEntry]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentGradebookEntry_CompetencyLevelDescriptor_CompetencyLevelDescriptorId] FOREIGN KEY([CompetencyLevelDescriptorId])
REFERENCES [edfi].[CompetencyLevelDescriptor] ([CompetencyLevelDescriptorId])
GO
ALTER TABLE [edfi].[StudentGradebookEntry] CHECK CONSTRAINT [FK_StudentGradebookEntry_CompetencyLevelDescriptor_CompetencyLevelDescriptorId]
GO
ALTER TABLE [edfi].[StudentGradebookEntry]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentGradebookEntry_GradebookEntry_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [GradebookEntryTitle], [DateAssigned])
REFERENCES [edfi].[GradebookEntry] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [GradebookEntryTitle], [DateAssigned])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[StudentGradebookEntry] CHECK CONSTRAINT [FK_StudentGradebookEntry_GradebookEntry_SchoolId]
GO
ALTER TABLE [edfi].[StudentGradebookEntry]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentGradebookEntry_StudentSectionAssociation_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate])
REFERENCES [edfi].[StudentSectionAssociation] ([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate])
GO
ALTER TABLE [edfi].[StudentGradebookEntry] CHECK CONSTRAINT [FK_StudentGradebookEntry_StudentSectionAssociation_StudentUSI]
GO
ALTER TABLE [edfi].[StudentIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentIdentificationCode_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentIdentificationCode] CHECK CONSTRAINT [FK_StudentIdentificationCode_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentIdentificationCode]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentIdentificationCode_StudentIdentificationSystemType_StudentIdentificationSystemTypeId] FOREIGN KEY([StudentIdentificationSystemTypeId])
REFERENCES [edfi].[StudentIdentificationSystemType] ([StudentIdentificationSystemTypeId])
GO
ALTER TABLE [edfi].[StudentIdentificationCode] CHECK CONSTRAINT [FK_StudentIdentificationCode_StudentIdentificationSystemType_StudentIdentificationSystemTypeId]
GO
ALTER TABLE [edfi].[StudentIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentIdentificationDocument_CountryType_IssuerCountryTypeId] FOREIGN KEY([IssuerCountryTypeId])
REFERENCES [edfi].[CountryType] ([CountryTypeId])
GO
ALTER TABLE [edfi].[StudentIdentificationDocument] CHECK CONSTRAINT [FK_StudentIdentificationDocument_CountryType_IssuerCountryTypeId]
GO
ALTER TABLE [edfi].[StudentIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentIdentificationDocument_IdentificationDocumentUseType_IdentificationDocumentUseTypeId] FOREIGN KEY([IdentificationDocumentUseTypeId])
REFERENCES [edfi].[IdentificationDocumentUseType] ([IdentificationDocumentUseTypeId])
GO
ALTER TABLE [edfi].[StudentIdentificationDocument] CHECK CONSTRAINT [FK_StudentIdentificationDocument_IdentificationDocumentUseType_IdentificationDocumentUseTypeId]
GO
ALTER TABLE [edfi].[StudentIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentIdentificationDocument_PersonalInformationVerificationType_PersonalInformationVerificationTypeId] FOREIGN KEY([PersonalInformationVerificationTypeId])
REFERENCES [edfi].[PersonalInformationVerificationType] ([PersonalInformationVerificationTypeId])
GO
ALTER TABLE [edfi].[StudentIdentificationDocument] CHECK CONSTRAINT [FK_StudentIdentificationDocument_PersonalInformationVerificationType_PersonalInformationVerificationTypeId]
GO
ALTER TABLE [edfi].[StudentIdentificationDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentIdentificationDocument_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentIdentificationDocument] CHECK CONSTRAINT [FK_StudentIdentificationDocument_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentIndicator]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentIndicator_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentIndicator] CHECK CONSTRAINT [FK_StudentIndicator_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInternationalAddress_AddressType_AddressTypeId] FOREIGN KEY([AddressTypeId])
REFERENCES [edfi].[AddressType] ([AddressTypeId])
GO
ALTER TABLE [edfi].[StudentInternationalAddress] CHECK CONSTRAINT [FK_StudentInternationalAddress_AddressType_AddressTypeId]
GO
ALTER TABLE [edfi].[StudentInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInternationalAddress_CountryType_CountryTypeId] FOREIGN KEY([CountryTypeId])
REFERENCES [edfi].[CountryType] ([CountryTypeId])
GO
ALTER TABLE [edfi].[StudentInternationalAddress] CHECK CONSTRAINT [FK_StudentInternationalAddress_CountryType_CountryTypeId]
GO
ALTER TABLE [edfi].[StudentInternationalAddress]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInternationalAddress_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentInternationalAddress] CHECK CONSTRAINT [FK_StudentInternationalAddress_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentInterventionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInterventionAssociation_Cohort_EducationOrganizationId] FOREIGN KEY([EducationOrganizationId], [CohortIdentifier])
REFERENCES [edfi].[Cohort] ([EducationOrganizationId], [CohortIdentifier])
GO
ALTER TABLE [edfi].[StudentInterventionAssociation] CHECK CONSTRAINT [FK_StudentInterventionAssociation_Cohort_EducationOrganizationId]
GO
ALTER TABLE [edfi].[StudentInterventionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInterventionAssociation_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
GO
ALTER TABLE [edfi].[StudentInterventionAssociation] CHECK CONSTRAINT [FK_StudentInterventionAssociation_Intervention]
GO
ALTER TABLE [edfi].[StudentInterventionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInterventionAssociation_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentInterventionAssociation] CHECK CONSTRAINT [FK_StudentInterventionAssociation_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness]  WITH CHECK ADD  CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_DiagnosisDescriptorId] FOREIGN KEY([DiagnosisDescriptorId])
REFERENCES [edfi].[DiagnosisDescriptor] ([DiagnosisDescriptorId])
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness] CHECK CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_DiagnosisDescriptorId]
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness]  WITH CHECK ADD  CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_GradeLevelDescriptorId] FOREIGN KEY([GradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness] CHECK CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_GradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_InterventionEffectivenessRatingType] FOREIGN KEY([InterventionEffectivenessRatingTypeId])
REFERENCES [edfi].[InterventionEffectivenessRatingType] ([InterventionEffectivenessRatingTypeId])
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness] CHECK CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_InterventionEffectivenessRatingType]
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_PopulationServedType_PopulationServedTypeId] FOREIGN KEY([PopulationServedTypeId])
REFERENCES [edfi].[PopulationServedType] ([PopulationServedTypeId])
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness] CHECK CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_PopulationServedType_PopulationServedTypeId]
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_StudentInterventionAssociation] FOREIGN KEY([StudentUSI], [InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[StudentInterventionAssociation] ([StudentUSI], [InterventionIdentificationCode], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentInterventionAssociationInterventionEffectiveness] CHECK CONSTRAINT [FK_StudentInterventionAssociationInterventionEffectiveness_StudentInterventionAssociation]
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent]  WITH CHECK ADD  CONSTRAINT [FK_StudentInterventionAttendanceEvent_AttendanceEventCategoryDescriptorId] FOREIGN KEY([AttendanceEventCategoryDescriptorId])
REFERENCES [edfi].[AttendanceEventCategoryDescriptor] ([AttendanceEventCategoryDescriptorId])
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent] CHECK CONSTRAINT [FK_StudentInterventionAttendanceEvent_AttendanceEventCategoryDescriptorId]
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInterventionAttendanceEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId] FOREIGN KEY([EducationalEnvironmentTypeId])
REFERENCES [edfi].[EducationalEnvironmentType] ([EducationalEnvironmentTypeId])
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent] CHECK CONSTRAINT [FK_StudentInterventionAttendanceEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId]
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInterventionAttendanceEvent_Intervention] FOREIGN KEY([InterventionIdentificationCode], [EducationOrganizationId])
REFERENCES [edfi].[Intervention] ([InterventionIdentificationCode], [EducationOrganizationId])
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent] CHECK CONSTRAINT [FK_StudentInterventionAttendanceEvent_Intervention]
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentInterventionAttendanceEvent_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentInterventionAttendanceEvent] CHECK CONSTRAINT [FK_StudentInterventionAttendanceEvent_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLanguages_LanguageDescriptor_LanguageDescriptorId] FOREIGN KEY([LanguageDescriptorId])
REFERENCES [edfi].[LanguageDescriptor] ([LanguageDescriptorId])
GO
ALTER TABLE [edfi].[StudentLanguage] CHECK CONSTRAINT [FK_StudentLanguages_LanguageDescriptor_LanguageDescriptorId]
GO
ALTER TABLE [edfi].[StudentLanguage]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLanguages_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentLanguage] CHECK CONSTRAINT [FK_StudentLanguages_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentLanguageUse]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLanguageUse_LanguageUseType_LanguageUseTypeId] FOREIGN KEY([LanguageUseTypeId])
REFERENCES [edfi].[LanguageUseType] ([LanguageUseTypeId])
GO
ALTER TABLE [edfi].[StudentLanguageUse] CHECK CONSTRAINT [FK_StudentLanguageUse_LanguageUseType_LanguageUseTypeId]
GO
ALTER TABLE [edfi].[StudentLanguageUse]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLanguageUse_StudentLanguages_StudentUSI] FOREIGN KEY([StudentUSI], [LanguageDescriptorId])
REFERENCES [edfi].[StudentLanguage] ([StudentUSI], [LanguageDescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentLanguageUse] CHECK CONSTRAINT [FK_StudentLanguageUse_StudentLanguages_StudentUSI]
GO
ALTER TABLE [edfi].[StudentLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLearningObjective_CompetencyLevelDescriptor_CompetencyLevelDescriptorId] FOREIGN KEY([CompetencyLevelDescriptorId])
REFERENCES [edfi].[CompetencyLevelDescriptor] ([CompetencyLevelDescriptorId])
GO
ALTER TABLE [edfi].[StudentLearningObjective] CHECK CONSTRAINT [FK_StudentLearningObjective_CompetencyLevelDescriptor_CompetencyLevelDescriptorId]
GO
ALTER TABLE [edfi].[StudentLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLearningObjective_GradingPeriod] FOREIGN KEY([GradingPeriodEducationOrganizationId], [GradingPeriodDescriptorId], [GradingPeriodBeginDate])
REFERENCES [edfi].[GradingPeriod] ([EducationOrganizationId], [GradingPeriodDescriptorId], [BeginDate])
GO
ALTER TABLE [edfi].[StudentLearningObjective] CHECK CONSTRAINT [FK_StudentLearningObjective_GradingPeriod]
GO
ALTER TABLE [edfi].[StudentLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLearningObjective_LearningObjective_Objective] FOREIGN KEY([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
REFERENCES [edfi].[LearningObjective] ([Objective], [AcademicSubjectDescriptorId], [ObjectiveGradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[StudentLearningObjective] CHECK CONSTRAINT [FK_StudentLearningObjective_LearningObjective_Objective]
GO
ALTER TABLE [edfi].[StudentLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLearningObjective_StudentProgramAssociation] FOREIGN KEY([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
REFERENCES [edfi].[StudentProgramAssociation] ([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
GO
ALTER TABLE [edfi].[StudentLearningObjective] CHECK CONSTRAINT [FK_StudentLearningObjective_StudentProgramAssociation]
GO
ALTER TABLE [edfi].[StudentLearningObjective]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLearningObjective_StudentSectionAssociation_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate])
REFERENCES [edfi].[StudentSectionAssociation] ([StudentUSI], [SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear], [BeginDate])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[StudentLearningObjective] CHECK CONSTRAINT [FK_StudentLearningObjective_StudentSectionAssociation_StudentUSI]
GO
ALTER TABLE [edfi].[StudentLearningStyle]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentLearningStyle_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentLearningStyle] CHECK CONSTRAINT [FK_StudentLearningStyle_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentMigrantEducationProgramAssociation]  WITH CHECK ADD  CONSTRAINT [FK_StudentMigrantEducationProgramAssociation_ContinuationOfServicesReasonDescriptorId] FOREIGN KEY([ContinuationOfServicesReasonDescriptorId])
REFERENCES [edfi].[ContinuationOfServicesReasonDescriptor] ([ContinuationOfServicesReasonDescriptorId])
GO
ALTER TABLE [edfi].[StudentMigrantEducationProgramAssociation] CHECK CONSTRAINT [FK_StudentMigrantEducationProgramAssociation_ContinuationOfServicesReasonDescriptorId]
GO
ALTER TABLE [edfi].[StudentMigrantEducationProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentMigrantEducationProgramAssociation_StudentProgramAssociation] FOREIGN KEY([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
REFERENCES [edfi].[StudentProgramAssociation] ([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentMigrantEducationProgramAssociation] CHECK CONSTRAINT [FK_StudentMigrantEducationProgramAssociation_StudentProgramAssociation]
GO
ALTER TABLE [edfi].[StudentOtherName]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentOtherName_OtherNameType_OtherNameTypeId] FOREIGN KEY([OtherNameTypeId])
REFERENCES [edfi].[OtherNameType] ([OtherNameTypeId])
GO
ALTER TABLE [edfi].[StudentOtherName] CHECK CONSTRAINT [FK_StudentOtherName_OtherNameType_OtherNameTypeId]
GO
ALTER TABLE [edfi].[StudentOtherName]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentOtherName_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentOtherName] CHECK CONSTRAINT [FK_StudentOtherName_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentParentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentParentAssociation_Parent_ParentUSI] FOREIGN KEY([ParentUSI])
REFERENCES [edfi].[Parent] ([ParentUSI])
GO
ALTER TABLE [edfi].[StudentParentAssociation] CHECK CONSTRAINT [FK_StudentParentAssociation_Parent_ParentUSI]
GO
ALTER TABLE [edfi].[StudentParentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentParentAssociation_RelationType_RelationTypeId] FOREIGN KEY([RelationTypeId])
REFERENCES [edfi].[RelationType] ([RelationTypeId])
GO
ALTER TABLE [edfi].[StudentParentAssociation] CHECK CONSTRAINT [FK_StudentParentAssociation_RelationType_RelationTypeId]
GO
ALTER TABLE [edfi].[StudentParentAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentParentAssociation_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentParentAssociation] CHECK CONSTRAINT [FK_StudentParentAssociation_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAssociation_EducationOrganization] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[StudentProgramAssociation] CHECK CONSTRAINT [FK_StudentProgramAssociation_EducationOrganization]
GO
ALTER TABLE [edfi].[StudentProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAssociation_Program] FOREIGN KEY([ProgramEducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
GO
ALTER TABLE [edfi].[StudentProgramAssociation] CHECK CONSTRAINT [FK_StudentProgramAssociation_Program]
GO
ALTER TABLE [edfi].[StudentProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAssociation_ReasonExitedDescriptor_ReasonExitedDescriptorId] FOREIGN KEY([ReasonExitedDescriptorId])
REFERENCES [edfi].[ReasonExitedDescriptor] ([ReasonExitedDescriptorId])
GO
ALTER TABLE [edfi].[StudentProgramAssociation] CHECK CONSTRAINT [FK_StudentProgramAssociation_ReasonExitedDescriptor_ReasonExitedDescriptorId]
GO
ALTER TABLE [edfi].[StudentProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAssociation_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentProgramAssociation] CHECK CONSTRAINT [FK_StudentProgramAssociation_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentProgramAssociationService]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAssociationService_ServiceDescriptor_ServiceDescriptorId] FOREIGN KEY([ServiceDescriptorId])
REFERENCES [edfi].[ServiceDescriptor] ([ServiceDescriptorId])
GO
ALTER TABLE [edfi].[StudentProgramAssociationService] CHECK CONSTRAINT [FK_StudentProgramAssociationService_ServiceDescriptor_ServiceDescriptorId]
GO
ALTER TABLE [edfi].[StudentProgramAssociationService]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAssociationService_StudentProgramAssociation] FOREIGN KEY([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
REFERENCES [edfi].[StudentProgramAssociation] ([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentProgramAssociationService] CHECK CONSTRAINT [FK_StudentProgramAssociationService_StudentProgramAssociation]
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent]  WITH CHECK ADD  CONSTRAINT [FK_StudentProgramAttendanceEvent_AttendanceEventCategoryDescriptorId] FOREIGN KEY([AttendanceEventCategoryDescriptorId])
REFERENCES [edfi].[AttendanceEventCategoryDescriptor] ([AttendanceEventCategoryDescriptorId])
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent] CHECK CONSTRAINT [FK_StudentProgramAttendanceEvent_AttendanceEventCategoryDescriptorId]
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAttendanceEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId] FOREIGN KEY([EducationalEnvironmentTypeId])
REFERENCES [edfi].[EducationalEnvironmentType] ([EducationalEnvironmentTypeId])
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent] CHECK CONSTRAINT [FK_StudentProgramAttendanceEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId]
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAttendanceEvent_EducationOrganization] FOREIGN KEY([EducationOrganizationId])
REFERENCES [edfi].[EducationOrganization] ([EducationOrganizationId])
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent] CHECK CONSTRAINT [FK_StudentProgramAttendanceEvent_EducationOrganization]
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAttendanceEvent_Program_ProgramTypeId] FOREIGN KEY([ProgramEducationOrganizationId], [ProgramTypeId], [ProgramName])
REFERENCES [edfi].[Program] ([EducationOrganizationId], [ProgramTypeId], [ProgramName])
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent] CHECK CONSTRAINT [FK_StudentProgramAttendanceEvent_Program_ProgramTypeId]
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramAttendanceEvent_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentProgramAttendanceEvent] CHECK CONSTRAINT [FK_StudentProgramAttendanceEvent_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentProgramParticipation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramParticipations_ProgramType_ProgramTypeId] FOREIGN KEY([ProgramTypeId])
REFERENCES [edfi].[ProgramType] ([ProgramTypeId])
GO
ALTER TABLE [edfi].[StudentProgramParticipation] CHECK CONSTRAINT [FK_StudentProgramParticipations_ProgramType_ProgramTypeId]
GO
ALTER TABLE [edfi].[StudentProgramParticipation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramParticipations_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentProgramParticipation] CHECK CONSTRAINT [FK_StudentProgramParticipations_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentProgramParticipationProgramCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramParticipationProgramCharacteristic_ProgramCharacteristicDescriptor_ProgramCharacteristicDescriptorId] FOREIGN KEY([ProgramCharacteristicDescriptorId])
REFERENCES [edfi].[ProgramCharacteristicDescriptor] ([ProgramCharacteristicDescriptorId])
GO
ALTER TABLE [edfi].[StudentProgramParticipationProgramCharacteristic] CHECK CONSTRAINT [FK_StudentProgramParticipationProgramCharacteristic_ProgramCharacteristicDescriptor_ProgramCharacteristicDescriptorId]
GO
ALTER TABLE [edfi].[StudentProgramParticipationProgramCharacteristic]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentProgramParticipationProgramCharacteristic_StudentProgramParticipation_ProgramTypeId] FOREIGN KEY([StudentUSI], [ProgramTypeId])
REFERENCES [edfi].[StudentProgramParticipation] ([StudentUSI], [ProgramTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentProgramParticipationProgramCharacteristic] CHECK CONSTRAINT [FK_StudentProgramParticipationProgramCharacteristic_StudentProgramParticipation_ProgramTypeId]
GO
ALTER TABLE [edfi].[StudentRace]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentRace_RaceType_RaceTypeId] FOREIGN KEY([RaceTypeId])
REFERENCES [edfi].[RaceType] ([RaceTypeId])
GO
ALTER TABLE [edfi].[StudentRace] CHECK CONSTRAINT [FK_StudentRace_RaceType_RaceTypeId]
GO
ALTER TABLE [edfi].[StudentRace]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentRace_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentRace] CHECK CONSTRAINT [FK_StudentRace_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_EntryGradeLevelDescriptorId] FOREIGN KEY([EntryGradeLevelDescriptorId])
REFERENCES [edfi].[GradeLevelDescriptor] ([GradeLevelDescriptorId])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_EntryGradeLevelDescriptorId]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_EntryGradeLevelReasonType_EntryGradeLevelReasonTypeId] FOREIGN KEY([EntryGradeLevelReasonTypeId])
REFERENCES [edfi].[EntryGradeLevelReasonType] ([EntryGradeLevelReasonTypeId])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_EntryGradeLevelReasonType_EntryGradeLevelReasonTypeId]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_EntryTypeDescriptor_EntryTypeDescriptorId] FOREIGN KEY([EntryTypeDescriptorId])
REFERENCES [edfi].[EntryTypeDescriptor] ([EntryTypeDescriptorId])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_EntryTypeDescriptor_EntryTypeDescriptorId]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_ExitWithdrawTypeDescriptor_ExitWithdrawTypeDescriptorId] FOREIGN KEY([ExitWithdrawTypeDescriptorId])
REFERENCES [edfi].[ExitWithdrawTypeDescriptor] ([ExitWithdrawTypeDescriptorId])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_ExitWithdrawTypeDescriptor_ExitWithdrawTypeDescriptorId]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_GraduationPlan] FOREIGN KEY([EducationOrganizationId], [GraduationPlanTypeDescriptorId], [GraduationSchoolYear])
REFERENCES [edfi].[GraduationPlan] ([EducationOrganizationId], [GraduationPlanTypeDescriptorId], [GraduationSchoolYear])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_GraduationPlan]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_ResidencyStatusDescriptor_ResidencyStatusDescriptorId] FOREIGN KEY([ResidencyStatusDescriptorId])
REFERENCES [edfi].[ResidencyStatusDescriptor] ([ResidencyStatusDescriptorId])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_ResidencyStatusDescriptor_ResidencyStatusDescriptorId]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_School_SchoolId]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_SchoolYearType_ClassOfSchoolYear] FOREIGN KEY([ClassOfSchoolYear])
REFERENCES [edfi].[SchoolYearType] ([SchoolYear])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_SchoolYearType_ClassOfSchoolYear]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_SchoolYearType_SchoolYear] FOREIGN KEY([SchoolYear])
REFERENCES [edfi].[SchoolYearType] ([SchoolYear])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_SchoolYearType_SchoolYear]
GO
ALTER TABLE [edfi].[StudentSchoolAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociation_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentSchoolAssociation] CHECK CONSTRAINT [FK_StudentSchoolAssociation_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentSchoolAssociationEducationPlan]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociationEducationPlans_EducationPlansType_EducationPlansTypeId] FOREIGN KEY([EducationPlanTypeId])
REFERENCES [edfi].[EducationPlanType] ([EducationPlanTypeId])
GO
ALTER TABLE [edfi].[StudentSchoolAssociationEducationPlan] CHECK CONSTRAINT [FK_StudentSchoolAssociationEducationPlans_EducationPlansType_EducationPlansTypeId]
GO
ALTER TABLE [edfi].[StudentSchoolAssociationEducationPlan]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAssociationEducationPlans_StudentSchoolAssociation_StudentUSI] FOREIGN KEY([StudentUSI], [SchoolId], [EntryDate])
REFERENCES [edfi].[StudentSchoolAssociation] ([StudentUSI], [SchoolId], [EntryDate])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentSchoolAssociationEducationPlan] CHECK CONSTRAINT [FK_StudentSchoolAssociationEducationPlans_StudentSchoolAssociation_StudentUSI]
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent]  WITH CHECK ADD  CONSTRAINT [FK_StudentSchoolAttendanceEvent_AttendanceEventCategoryDescriptorId] FOREIGN KEY([AttendanceEventCategoryDescriptorId])
REFERENCES [edfi].[AttendanceEventCategoryDescriptor] ([AttendanceEventCategoryDescriptorId])
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent] CHECK CONSTRAINT [FK_StudentSchoolAttendanceEvent_AttendanceEventCategoryDescriptorId]
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAttendanceEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId] FOREIGN KEY([EducationalEnvironmentTypeId])
REFERENCES [edfi].[EducationalEnvironmentType] ([EducationalEnvironmentTypeId])
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent] CHECK CONSTRAINT [FK_StudentSchoolAttendanceEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId]
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAttendanceEvent_School_SchoolId] FOREIGN KEY([SchoolId])
REFERENCES [edfi].[School] ([SchoolId])
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent] CHECK CONSTRAINT [FK_StudentSchoolAttendanceEvent_School_SchoolId]
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAttendanceEvent_Session_SchoolId] FOREIGN KEY([SchoolId], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Session] ([SchoolId], [TermTypeId], [SchoolYear])
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent] CHECK CONSTRAINT [FK_StudentSchoolAttendanceEvent_Session_SchoolId]
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSchoolAttendanceEvent_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentSchoolAttendanceEvent] CHECK CONSTRAINT [FK_StudentSchoolAttendanceEvent_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentSectionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSectionAssociation_RepeatIdentifierType_RepeatIdentifierTypeId] FOREIGN KEY([RepeatIdentifierTypeId])
REFERENCES [edfi].[RepeatIdentifierType] ([RepeatIdentifierTypeId])
GO
ALTER TABLE [edfi].[StudentSectionAssociation] CHECK CONSTRAINT [FK_StudentSectionAssociation_RepeatIdentifierType_RepeatIdentifierTypeId]
GO
ALTER TABLE [edfi].[StudentSectionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSectionAssociation_Section_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Section] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[StudentSectionAssociation] CHECK CONSTRAINT [FK_StudentSectionAssociation_Section_SchoolId]
GO
ALTER TABLE [edfi].[StudentSectionAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSectionAssociation_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentSectionAssociation] CHECK CONSTRAINT [FK_StudentSectionAssociation_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSectionAttendanceEvent_AttendanceEventCategoryDescriptorId] FOREIGN KEY([AttendanceEventCategoryDescriptorId])
REFERENCES [edfi].[AttendanceEventCategoryDescriptor] ([AttendanceEventCategoryDescriptorId])
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent] CHECK CONSTRAINT [FK_StudentSectionAttendanceEvent_AttendanceEventCategoryDescriptorId]
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSectionAttendanceEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId] FOREIGN KEY([EducationalEnvironmentTypeId])
REFERENCES [edfi].[EducationalEnvironmentType] ([EducationalEnvironmentTypeId])
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent] CHECK CONSTRAINT [FK_StudentSectionAttendanceEvent_EducationalEnvironmentType_EducationalEnvironmentTypeId]
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSectionAttendanceEvent_Section_SchoolId] FOREIGN KEY([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
REFERENCES [edfi].[Section] ([SchoolId], [ClassPeriodName], [ClassroomIdentificationCode], [LocalCourseCode], [TermTypeId], [SchoolYear])
ON UPDATE CASCADE
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent] CHECK CONSTRAINT [FK_StudentSectionAttendanceEvent_Section_SchoolId]
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSectionAttendanceEvent_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
GO
ALTER TABLE [edfi].[StudentSectionAttendanceEvent] CHECK CONSTRAINT [FK_StudentSectionAttendanceEvent_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentSpecialEducationProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSpecialEducationProgramAssociation_SpecialEducationSettingDescriptor_SpecialEducationSettingDescriptorId] FOREIGN KEY([SpecialEducationSettingDescriptorId])
REFERENCES [edfi].[SpecialEducationSettingDescriptor] ([SpecialEducationSettingDescriptorId])
GO
ALTER TABLE [edfi].[StudentSpecialEducationProgramAssociation] CHECK CONSTRAINT [FK_StudentSpecialEducationProgramAssociation_SpecialEducationSettingDescriptor_SpecialEducationSettingDescriptorId]
GO
ALTER TABLE [edfi].[StudentSpecialEducationProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSpecialEducationProgramAssociation_StudentProgramAssociation] FOREIGN KEY([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
REFERENCES [edfi].[StudentProgramAssociation] ([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentSpecialEducationProgramAssociation] CHECK CONSTRAINT [FK_StudentSpecialEducationProgramAssociation_StudentProgramAssociation]
GO
ALTER TABLE [edfi].[StudentSpecialEducationProgramAssociationServiceProvider]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSpecialEducationProgramAssociationServiceProvider_Staff_StaffUSI] FOREIGN KEY([StaffUSI])
REFERENCES [edfi].[Staff] ([StaffUSI])
GO
ALTER TABLE [edfi].[StudentSpecialEducationProgramAssociationServiceProvider] CHECK CONSTRAINT [FK_StudentSpecialEducationProgramAssociationServiceProvider_Staff_StaffUSI]
GO
ALTER TABLE [edfi].[StudentSpecialEducationProgramAssociationServiceProvider]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentSpecialEducationProgramAssociationServiceProvider_StudentSpecialEducationProgramAssociation] FOREIGN KEY([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
REFERENCES [edfi].[StudentSpecialEducationProgramAssociation] ([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentSpecialEducationProgramAssociationServiceProvider] CHECK CONSTRAINT [FK_StudentSpecialEducationProgramAssociationServiceProvider_StudentSpecialEducationProgramAssociation]
GO
ALTER TABLE [edfi].[StudentTelephone]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentTelephone_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentTelephone] CHECK CONSTRAINT [FK_StudentTelephone_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentTelephone]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentTelephone_TelephoneNumberType_TelephoneNumberTypeId] FOREIGN KEY([TelephoneNumberTypeId])
REFERENCES [edfi].[TelephoneNumberType] ([TelephoneNumberTypeId])
GO
ALTER TABLE [edfi].[StudentTelephone] CHECK CONSTRAINT [FK_StudentTelephone_TelephoneNumberType_TelephoneNumberTypeId]
GO
ALTER TABLE [edfi].[StudentTitleIPartAProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentTitleIPartAProgramAssociation_StudentProgramAssociation] FOREIGN KEY([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
REFERENCES [edfi].[StudentProgramAssociation] ([StudentUSI], [ProgramTypeId], [ProgramName], [ProgramEducationOrganizationId], [BeginDate], [EducationOrganizationId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentTitleIPartAProgramAssociation] CHECK CONSTRAINT [FK_StudentTitleIPartAProgramAssociation_StudentProgramAssociation]
GO
ALTER TABLE [edfi].[StudentTitleIPartAProgramAssociation]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentTitleIPartAProgramAssociation_TitleIPartAParticipantType_TitleIPartAParticipantTypeId] FOREIGN KEY([TitleIPartAParticipantTypeId])
REFERENCES [edfi].[TitleIPartAParticipantType] ([TitleIPartAParticipantTypeId])
GO
ALTER TABLE [edfi].[StudentTitleIPartAProgramAssociation] CHECK CONSTRAINT [FK_StudentTitleIPartAProgramAssociation_TitleIPartAParticipantType_TitleIPartAParticipantTypeId]
GO
ALTER TABLE [edfi].[StudentVisa]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentVisa_Student_StudentUSI] FOREIGN KEY([StudentUSI])
REFERENCES [edfi].[Student] ([StudentUSI])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[StudentVisa] CHECK CONSTRAINT [FK_StudentVisa_Student_StudentUSI]
GO
ALTER TABLE [edfi].[StudentVisa]  WITH NOCHECK ADD  CONSTRAINT [FK_StudentVisa_VisaType_VisaTypeId] FOREIGN KEY([VisaTypeId])
REFERENCES [edfi].[VisaType] ([VisaTypeId])
GO
ALTER TABLE [edfi].[StudentVisa] CHECK CONSTRAINT [FK_StudentVisa_VisaType_VisaTypeId]
GO
ALTER TABLE [edfi].[TeachingCredentialDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_TeachingCredentialDescriptor_Descriptor_DescriptorId] FOREIGN KEY([TeachingCredentialDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[TeachingCredentialDescriptor] CHECK CONSTRAINT [FK_TeachingCredentialDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[TeachingCredentialDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_TeachingCredentialDescriptor_TeachingCredentialType_TeachingCredentialTypeId] FOREIGN KEY([TeachingCredentialTypeId])
REFERENCES [edfi].[TeachingCredentialType] ([TeachingCredentialTypeId])
GO
ALTER TABLE [edfi].[TeachingCredentialDescriptor] CHECK CONSTRAINT [FK_TeachingCredentialDescriptor_TeachingCredentialType_TeachingCredentialTypeId]
GO
ALTER TABLE [edfi].[WeaponDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_WeaponDescriptor_Descriptor_DescriptorId] FOREIGN KEY([WeaponDescriptorId])
REFERENCES [edfi].[Descriptor] ([DescriptorId])
ON DELETE CASCADE
GO
ALTER TABLE [edfi].[WeaponDescriptor] CHECK CONSTRAINT [FK_WeaponDescriptor_Descriptor_DescriptorId]
GO
ALTER TABLE [edfi].[WeaponDescriptor]  WITH NOCHECK ADD  CONSTRAINT [FK_WeaponDescriptor_WeaponsType_WeaponsTypeId] FOREIGN KEY([WeaponTypeId])
REFERENCES [edfi].[WeaponType] ([WeaponTypeId])
GO
ALTER TABLE [edfi].[WeaponDescriptor] CHECK CONSTRAINT [FK_WeaponDescriptor_WeaponsType_WeaponsTypeId]
GO
/****** Object:  StoredProcedure [dbo].[sp_alterdiagram]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_alterdiagram]
	(
		@diagramname 	sysname,
		@owner_id	int	= null,
		@version 	int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId 			int
		declare @retval 		int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @ShouldChangeUID	int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid ARG', 16, 1)
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();	 
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;
	
		select @ShouldChangeUID = 0
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		
		if(@DiagId IS NULL or (@IsDbo = 0 and @theId <> @UIDFound))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end
	
		if(@IsDbo <> 0)
		begin
			if(@UIDFound is null or USER_NAME(@UIDFound) is null) -- invalid principal_id
			begin
				select @ShouldChangeUID = 1 ;
			end
		end

		-- update dds data			
		update dbo.sysdiagrams set definition = @definition where diagram_id = @DiagId ;

		-- change owner
		if(@ShouldChangeUID = 1)
			update dbo.sysdiagrams set principal_id = @theId where diagram_id = @DiagId ;

		-- update dds version
		if(@version is not null)
			update dbo.sysdiagrams set version = @version where diagram_id = @DiagId ;

		return 0
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_creatediagram]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_creatediagram]
	(
		@diagramname 	sysname,
		@owner_id		int	= null, 	
		@version 		int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId int
		declare @retval int
		declare @IsDbo	int
		declare @userName sysname
		if(@version is null or @diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID(); 
		select @IsDbo = IS_MEMBER(N'db_owner');
		revert; 
		
		if @owner_id is null
		begin
			select @owner_id = @theId;
		end
		else
		begin
			if @theId <> @owner_id
			begin
				if @IsDbo = 0
				begin
					RAISERROR (N'E_INVALIDARG', 16, 1);
					return -1
				end
				select @theId = @owner_id
			end
		end
		-- next 2 line only for test, will be removed after define name unique
		if EXISTS(select diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @diagramname)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end
	
		insert into dbo.sysdiagrams(name, principal_id , version, definition)
				VALUES(@diagramname, @theId, @version, @definition) ;
		
		select @retval = @@IDENTITY 
		return @retval
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_dropdiagram]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_dropdiagram]
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT; 
		
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		delete from dbo.sysdiagrams where diagram_id = @DiagId;
	
		return 0;
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_helpdiagramdefinition]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_helpdiagramdefinition]
	(
		@diagramname 	sysname,
		@owner_id	int	= null 		
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 		int
		declare @IsDbo 		int
		declare @DiagId		int
		declare @UIDFound	int
	
		if(@diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert; 
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname;
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId ))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		select version, definition FROM dbo.sysdiagrams where diagram_id = @DiagId ; 
		return 0
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_helpdiagrams]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_helpdiagrams]
	(
		@diagramname sysname = NULL,
		@owner_id int = NULL
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		DECLARE @user sysname
		DECLARE @dboLogin bit
		EXECUTE AS CALLER;
			SET @user = USER_NAME();
			SET @dboLogin = CONVERT(bit,IS_MEMBER('db_owner'));
		REVERT;
		SELECT
			[Database] = DB_NAME(),
			[Name] = name,
			[ID] = diagram_id,
			[Owner] = USER_NAME(principal_id),
			[OwnerID] = principal_id
		FROM
			sysdiagrams
		WHERE
			(@dboLogin = 1 OR USER_NAME(principal_id) = @user) AND
			(@diagramname IS NULL OR name = @diagramname) AND
			(@owner_id IS NULL OR principal_id = @owner_id)
		ORDER BY
			4, 5, 1
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_renamediagram]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_renamediagram]
	(
		@diagramname 		sysname,
		@owner_id		int	= null,
		@new_diagramname	sysname
	
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @DiagIdTarg		int
		declare @u_name			sysname
		if((@diagramname is null) or (@new_diagramname is null))
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;
	
		select @u_name = USER_NAME(@owner_id)
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		-- if((@u_name is not null) and (@new_diagramname = @diagramname))	-- nothing will change
		--	return 0;
	
		if(@u_name is null)
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @new_diagramname
		else
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @owner_id and name = @new_diagramname
	
		if((@DiagIdTarg is not null) and  @DiagId <> @DiagIdTarg)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end		
	
		if(@u_name is null)
			update dbo.sysdiagrams set [name] = @new_diagramname, principal_id = @theId where diagram_id = @DiagId
		else
			update dbo.sysdiagrams set [name] = @new_diagramname where diagram_id = @DiagId
		return 0
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_ssis_addlogentry]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_ssis_addlogentry]  
	@event sysname,  
	@computer nvarchar(128),  
	@operator nvarchar(128),  
	@source nvarchar(1024),  
	@sourceid uniqueidentifier,  
	@executionid uniqueidentifier,  
	@starttime datetime,  
	@endtime datetime,  
	@datacode int,  
	@databytes image,  
	@message nvarchar(2048)
  AS  
	INSERT INTO sysssislog (      
		event,      
		computer,      
		operator,      
		source,      
		sourceid,      
		executionid,      
		starttime,      
		endtime,      
		datacode,      
		databytes,      
		message )  
	VALUES (      
		@event,      
		@computer,      
		@operator,      
		@source,      
		@sourceid,      
		@executionid,      
		@starttime,      
		@endtime,      
		@datacode,      
		@databytes,      
		@message )  
RETURN 0
--
--

GO
/****** Object:  StoredProcedure [dbo].[sp_upgraddiagrams]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_upgraddiagrams]
	AS
	BEGIN
		IF OBJECT_ID(N'dbo.sysdiagrams') IS NOT NULL
			return 0;
	
		CREATE TABLE dbo.sysdiagrams
		(
			name sysname NOT NULL,
			principal_id int NOT NULL,	-- we may change it to varbinary(85)
			diagram_id int PRIMARY KEY IDENTITY,
			version int,
	
			definition varbinary(max)
			CONSTRAINT UK_principal_name UNIQUE
			(
				principal_id,
				name
			)
		);


		/* Add this if we need to have some form of extended properties for diagrams */
		/*
		IF OBJECT_ID(N'dbo.sysdiagram_properties') IS NULL
		BEGIN
			CREATE TABLE dbo.sysdiagram_properties
			(
				diagram_id int,
				name sysname,
				value varbinary(max) NOT NULL
			)
		END
		*/

		IF OBJECT_ID(N'dbo.dtproperties') IS NOT NULL
		begin
			insert into dbo.sysdiagrams
			(
				[name],
				[principal_id],
				[version],
				[definition]
			)
			select	 
				convert(sysname, dgnm.[uvalue]),
				DATABASE_PRINCIPAL_ID(N'dbo'),			-- will change to the sid of sa
				0,							-- zero for old format, dgdef.[version],
				dgdef.[lvalue]
			from dbo.[dtproperties] dgnm
				inner join dbo.[dtproperties] dggd on dggd.[property] = 'DtgSchemaGUID' and dggd.[objectid] = dgnm.[objectid]	
				inner join dbo.[dtproperties] dgdef on dgdef.[property] = 'DtgSchemaDATA' and dgdef.[objectid] = dgnm.[objectid]
				
			where dgnm.[property] = 'DtgSchemaNAME' and dggd.[uvalue] like N'_EA3E6268-D998-11CE-9454-00AA00A3F36E_' 
			return 2;
		end
		return 1;
	END
	
GO
/****** Object:  StoredProcedure [util].[DashboardAssociation]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [util].[DashboardAssociation] (
	@AssociationFlag bit = 1
) AS
BEGIN

	SET NOCOUNT ON

	-----------------------------------
	-- Prep steps
	-----------------------------------

	DECLARE @DashboardDatabaseName nvarchar(255)
	DECLARE @DashboardSchemaTableId int, @TableSchema nvarchar(255), @TableName nvarchar(255)
	DECLARE @SQLCommand nvarchar(4000)

	TRUNCATE TABLE util.DashboardSchemaTable

	SELECT @DashboardDatabaseName = REPLACE(DB_NAME(), '_EdFi_', '_Dashboard_')

	-----------------------------------
	-- Create synonym for tables in the DashboardIntegration database
	-----------------------------------

	IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @DashboardDatabaseName) AND @AssociationFlag = 1
	BEGIN
		IF SCHEMA_ID('domain') IS NULL
			EXEC ('CREATE SCHEMA domain authorization dbo')

		IF SCHEMA_ID('metric') IS NULL
			EXEC ('CREATE SCHEMA metric authorization dbo')

		SELECT @SQLCommand = 'INSERT INTO util.DashboardSchemaTable(TableSchema, TableName) ' +
		'SELECT TABLE_SCHEMA, TABLE_NAME ' +
		'FROM ' + @DashboardDatabaseName + '.INFORMATION_SCHEMA.TABLES ' +
		'WHERE TABLE_SCHEMA IN (''domain'', ''metric'') ' +
		'AND TABLE_TYPE = ''BASE TABLE'''
		EXEC sp_executesql @SQLCommand

		WHILE EXISTS (SELECT 1 FROM util.DashboardSchemaTable)
		BEGIN
			SELECT 
				@DashboardSchemaTableId = DashboardSchemaTableId,
				@TableSchema = TableSchema,
				@TableName = TableName
			FROM util.DashboardSchemaTable
			ORDER BY DashboardSchemaTableId
			
			SELECT @SQLCommand = 'IF OBJECT_ID(''[' + @TableSchema + '].[' + @TableName + ']'', ''SN'') IS NOT NULL DROP SYNONYM [' + @TableSchema + '].[' + @TableName + ']'
			EXEC sp_executesql @SQLCommand

			SELECT @SQLCommand = 'CREATE SYNONYM [' + @TableSchema + '].[' + @TableName + '] FOR ' + @DashboardDatabaseName + '.[' + @TableSchema + '].[' + @TableName + ']'
			IF @DashboardDatabaseName <> DB_NAME()
				EXEC sp_executesql @SQLCommand
			
			DELETE util.DashboardSchemaTable
			WHERE DashboardSchemaTableId = @DashboardSchemaTableId
		END
	END


	-----------------------------------
	-- Drop synonym for tables in the DashboardIntegration database
	-----------------------------------

	ELSE BEGIN

		INSERT INTO util.DashboardSchemaTable(TableSchema, TableName)
		SELECT SCHEMA_NAME(schema_id), [name]
		FROM sys.all_objects
		WHERE type = 'sn'
		AND SCHEMA_NAME(schema_id) IN ('domain', 'metric')		

		WHILE EXISTS (SELECT 1 FROM util.DashboardSchemaTable)
		BEGIN
			SELECT 
				@DashboardSchemaTableId = DashboardSchemaTableId,
				@TableSchema = TableSchema,
				@TableName = TableName
			FROM util.DashboardSchemaTable
			ORDER BY DashboardSchemaTableId
			
			SELECT @SQLCommand = 'IF OBJECT_ID(''[' + @TableSchema + '].[' + @TableName + ']'', ''SN'') IS NOT NULL DROP SYNONYM [' + @TableSchema + '].[' + @TableName + ']'
			EXEC sp_executesql @SQLCommand
			
			DELETE util.DashboardSchemaTable
			WHERE DashboardSchemaTableId = @DashboardSchemaTableId
		END

		IF SCHEMA_ID('domain') IS NOT NULL
		BEGIN TRY
			EXEC ('DROP SCHEMA domain')
		END TRY
		BEGIN CATCH
			-- Ignore error
		END CATCH

		IF SCHEMA_ID('metric') IS NOT NULL
		BEGIN TRY
			EXEC ('DROP SCHEMA metric')
		END TRY
		BEGIN CATCH
			-- Ignore error
		END CATCH
	END
	
	SET NOCOUNT OFF

END
--
--

GO
/****** Object:  StoredProcedure [util].[EdFiExceptionEnhancement]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [util].[EdFiExceptionEnhancement] (
	@TimeoutInSeconds int = 2147483647
) AS
BEGIN

	SET NOCOUNT ON

	DECLARE @SQL nvarchar(MAX), @ErrorMessage nvarchar(MAX)
	DECLARE @EdFiExceptionId int, @TableName nvarchar(255), @ComponentName nvarchar(255), @ColumnNameList nvarchar(4000), @ColumnValueList nvarchar(4000)
	DECLARE @LookupCondition nvarchar(4000)
	DECLARE @LookupUnionTag nvarchar(4000), @LookupConditionAND nvarchar(4000), @LookupConditionOR nvarchar(4000)
	DECLARE @StartTime datetime = GETDATE()
	DECLARE @LookupErrorCode int = -1071607778


	-----------------------------------
	-- Handle cases where the Destination component that writes to the EdFiException table is not mapped properly
	-----------------------------------

	-- If ErrorCode is not mapped in the Destination component, we will need to fix the package.
	-- In the meantime, deduce the ErrorCode from ErrorDescription if possible.
	UPDATE edfi.EdFiException
	SET ErrorCode = CASE WHEN ErrorDescription LIKE 'Row yielded no match during lookup%' THEN @LookupErrorCode ELSE 0 END
	WHERE ErrorCode IS NULL
	AND ErrorDescription IS NOT NULL

	UPDATE edfi.EdFiException
	SET ErrorMessage = 'At least one of these column is null: TableName, ColumnNameList, ColumnValueList, and ErrorCode. Please check the Destination component that writes to the edfi.EdFiException table.'
	WHERE ErrorCode IS NULL
	OR TableName + ColumnNameList + ColumnValueList IS NULL


	-----------------------------------
	-- Lookup exceptions
	-----------------------------------
	
	-- Hardcode ErrorMessage for lookup exceptions
	UPDATE edfi.EdFiException
	SET ErrorMessage = 'No match during lookup'
	WHERE ErrorCode = @LookupErrorCode

	-- Replace ExceptionLevel for lookup for Staff and Student
	UPDATE edfi.EdFiException
	SET ExceptionLevel = 'EntityNotFound'
	WHERE TableName IN ('edfi.Staff', 'edfi.Student')
	AND ErrorCode = @LookupErrorCode


	-----------------------------------
	-- Run insert statements to capture error messages for non Lookup exceptions
	-----------------------------------

	DECLARE @EdFiExceptionTable TABLE (
		EdFiExceptionId			int,
		TableName				nvarchar(255),
		ColumnNameList			nvarchar(4000),
		ColumnValueList			nvarchar(4000)
	)

	INSERT INTO @EdFiExceptionTable
	SELECT EdFiExceptionId, TableName, ColumnNameList, ColumnValueList
	FROM edfi.EdFiException
	WHERE ErrorCode <> @LookupErrorCode
	AND ErrorMessage IS NULL

	WHILE EXISTS (SELECT 1 FROM @EdFiExceptionTable) AND DATEDIFF(SECOND, @StartTime, GETDATE()) < @TimeoutInSeconds
	BEGIN
		SELECT TOP 1 
			@EdFiExceptionId = EdFiExceptionId,
			@TableName = TableName,
			@ColumnNameList = ColumnNameList,
			@ColumnValueList = ColumnValueList
		FROM @EdFiExceptionTable

		SELECT @SQL = 'INSERT INTO ' + @TableName + '(' + @ColumnNameList + ') SELECT ' + @ColumnValueList

		-----------------------------------
		-- Run the insert statement in a TRY block to trap the error. Roll back if it goes through.
		-----------------------------------
		BEGIN TRANSACTION
		BEGIN TRY
			SELECT @ErrorMessage = 'No Error'
			EXEC sp_executesql @SQL
		END TRY
		BEGIN CATCH
			SELECT @ErrorMessage = ERROR_MESSAGE()
		END CATCH
		ROLLBACK


		-----------------------------------
		-- Remove row-specific information so that ErrorMessage remains generic
		-----------------------------------
		IF @ErrorMessage LIKE '%The duplicate key value is%'
			SELECT @ErrorMessage = RTRIM(LEFT(@ErrorMessage, CHARINDEX(' The duplicate key value is', @ErrorMessage)))

		IF @ErrorMessage LIKE '%The conversion of the varchar value % overflowed an int column%'
			SELECT @ErrorMessage = 'The conversion of the varchar value overflowed an int column'


		-----------------------------------
		-- final
		-----------------------------------
		UPDATE edfi.EdFiException
		SET ErrorMessage = @ErrorMessage
		WHERE EdFiExceptionId = @EdFiExceptionId
		
		DELETE @EdFiExceptionTable
		WHERE EdFiExceptionId = @EdFiExceptionId
	END
	

	-----------------------------------
	-- Populate LookupCondition from ColumnNameList and ColumnValueList for Lookup exceptions
	-----------------------------------

	UPDATE edfi.EdFiException
	SET LookupCondition = ColumnNameList + CASE ColumnValueList WHEN 'NULL' THEN ' IS ' ELSE '=' END  + ColumnValueList
	WHERE ErrorCode = @LookupErrorCode
	AND ColumnNameList NOT LIKE '%,%'

	DECLARE @LookupExceptionTable TABLE (
		EdFiExceptionId			int,
		ComponentName			nvarchar(255),
		ColumnNameList			nvarchar(4000),
		ColumnValueList			nvarchar(4000)
	)

	INSERT INTO @LookupExceptionTable
	SELECT EdFiExceptionId, ComponentName, ColumnNameList, ColumnValueList
	FROM edfi.EdFiException
	WHERE ErrorCode = @LookupErrorCode
	AND LookupCondition IS NULL

	DECLARE @LookupConditionClause TABLE(ColumnName nvarchar(255), ConditionClause nvarchar(4000))

	WHILE EXISTS (SELECT 1 FROM @LookupExceptionTable) AND DATEDIFF(SECOND, @StartTime, GETDATE()) < @TimeoutInSeconds
	BEGIN
		SELECT TOP 1 
			@EdFiExceptionId = EdFiExceptionId,
			@ComponentName = ComponentName,
			@ColumnNameList = ColumnNameList,
			@ColumnValueList = ColumnValueList,
			@LookupCondition = '',
			@LookupUnionTag = '',
			@LookupConditionAND = '',
			@LookupConditionOR = ''
		FROM @LookupExceptionTable
		
		DELETE @LookupConditionClause
		INSERT INTO @LookupConditionClause(ColumnName, ConditionClause)
		SELECT a.ColumnName, a.ColumnName + CASE b.ColumnValue WHEN 'NULL' THEN ' IS ' ELSE '=' END + b.ColumnValue as ConditionClause
		FROM 
			(SELECT Id, Token as ColumnName FROM util.Split((SELECT ColumnNameList FROM edfi.EdFiException WHERE EdFiExceptionId = @EdFiExceptionId), ',')) a INNER JOIN
			(SELECT Id, Token as ColumnValue FROM util.Split((SELECT ColumnValueList FROM edfi.EdFiException WHERE EdFiExceptionId = @EdFiExceptionId), ',')) b
				ON a.Id = b.Id

		IF @ComponentName NOT LIKE '%@LookupUnion%'
		BEGIN
			SELECT @LookupCondition = @LookupCondition + ConditionClause + ' AND '
			FROM @LookupConditionClause

			SELECT @LookupCondition = LEFT(@LookupCondition, NULLIF(LEN(@LookupCondition), 0) - 4)		-- remove trailing AND
		END
		ELSE BEGIN
			SELECT @LookupUnionTag = (SELECT TOP 1 Token FROM util.Split(@ComponentName, ' ') WHERE Token LIKE '%@LookupUnion%')			

			SELECT 
				@LookupConditionOR  = @LookupConditionOR  + CASE WHEN b.ColumnName IS NULL THEN + a.ConditionClause + ' OR ' ELSE '' END,
				@LookupConditionAND = @LookupConditionAND + CASE WHEN b.ColumnName IS NOT NULL THEN + a.ConditionClause + ' AND ' ELSE '' END
			FROM 
				@LookupConditionClause a LEFT OUTER JOIN
				(SELECT Token as ColumnName FROM util.Split(@LookupUnionTag, '-') WHERE Token <> '@LookupUnion') b
					ON a.ColumnName = b.ColumnName

			SELECT @LookupConditionOR  = LEFT(@LookupConditionOR,  NULLIF(LEN(@LookupConditionOR), 0)  - 3)		-- remove trailing OR
			SELECT @LookupConditionAND = LEFT(@LookupConditionAND, NULLIF(LEN(@LookupConditionAND), 0) - 4)		-- remove trailing AND
			SELECT @LookupCondition = ISNULL(@LookupConditionAND + ' AND ', '') + ISNULL(NULLIF('(' + @LookupConditionOR + ')', '()'), '')

		END

		UPDATE edfi.EdFiException
		SET LookupCondition = ISNULL(@LookupCondition, '')
		WHERE EdFiExceptionId = @EdFiExceptionId
		
		DELETE @LookupExceptionTable
		WHERE EdFiExceptionId = @EdFiExceptionId
	END
	
	UPDATE edfi.EdFiException
	SET LookupCondition = ''
	WHERE LookupCondition IS NULL
	
	SET NOCOUNT OFF
END
--
--

GO
/****** Object:  StoredProcedure [util].[EdFiPopulationAnalysis]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [util].[EdFiPopulationAnalysis] (
	@IntegrationTempKeyword nvarchar(255) = 'Temp',
	@StagingKeyword nvarchar(255) = ''
)
AS
BEGIN

	SET NOCOUNT ON

	-----------------------------------
	-- Prep steps
	-----------------------------------

	DECLARE @EdFiPopulationId int
	DECLARE @SQLCommand nvarchar(4000), @RecordCount int, @MostRecentDate date
	DECLARE @PriorSQLCommand nvarchar(4000), @PriorRecordCount int, @PriorMostRecentDate date
	DECLARE @PriorDatabaseName nvarchar(255)
	DECLARE @EdFiPopulation TABLE (EdFiPopulationId int primary key, TableSchema nvarchar(255), TableName nvarchar(255))
	
	SELECT @PriorDatabaseName = REPLACE(DB_NAME(), @IntegrationTempKeyword, @StagingKeyword)
	IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = @PriorDatabaseName)
		SELECT @PriorDatabaseName = DB_NAME()
	
	TRUNCATE TABLE util.EdFiPopulation
	
	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'StudentSectionAttendanceEvent')
		SELECT 
			@SQLCommand		 = 'SELECT @MostRecentDate = MAX(EventDate) FROM edfi.StudentSectionAttendanceEvent WITH (NOLOCK)',
			@PriorSQLCommand = 'SELECT @PriorMostRecentDate = MAX(EventDate) FROM [' + @PriorDatabaseName + '].edfi.StudentSectionAttendanceEvent WITH (NOLOCK)'
	ELSE
		SELECT 
			@SQLCommand		 = 'SELECT @MostRecentDate = MAX(EventDate) FROM edfi.AttendanceEvent WITH (NOLOCK)',
			@PriorSQLCommand = 'SELECT @PriorMostRecentDate = MAX(EventDate) FROM [' + @PriorDatabaseName + '].edfi.AttendanceEvent WITH (NOLOCK)'
	
	EXEC sp_executesql @SQLCommand, N'@MostRecentDate date output',  @MostRecentDate output
	EXEC sp_executesql @PriorSQLCommand, N'@PriorMostRecentDate date output', @PriorMostRecentDate output

	INSERT INTO util.EdFiPopulation(TableSchema, TableName, MostRecentDate, PriorMostRecentDate, DatabaseName, PriorDatabaseName)
	SELECT TABLE_SCHEMA, TABLE_NAME, @MostRecentDate, @PriorMostRecentDate, DB_NAME(), @PriorDatabaseName
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME NOT LIKE '%Type'
	AND TABLE_NAME NOT IN ('EdFiException', 'sysssislog')
	AND TABLE_TYPE = 'BASE TABLE'
	AND TABLE_SCHEMA = 'edfi'
	ORDER BY TABLE_NAME

	INSERT INTO @EdFiPopulation
	SELECT EdFiPopulationId, TableSchema, TableName 
	FROM util.EdFiPopulation


	-----------------------------------
	-- Loop through each table and select count(1)
	-----------------------------------

	WHILE EXISTS (SELECT 1 FROM @EdFiPopulation)
	BEGIN
		SELECT TOP 1 
			@EdFiPopulationId = EdFiPopulationId,
			@SQLCommand = 'SELECT @RecordCount = COUNT(1) FROM [' + TableSchema + '].[' + TableName + '] WITH (NOLOCK)',
			@PriorSQLCommand	= 'SELECT @PriorRecordCount = COUNT(1) FROM [' + @PriorDatabaseName + '].[' + TableSchema + '].[' + TableName + '] WITH (NOLOCK)',
			@RecordCount = 0,
			@PriorRecordCount = 0
		FROM @EdFiPopulation
		ORDER BY EdFiPopulationId

		BEGIN TRY
		EXEC sp_executesql @SQLCommand, N'@RecordCount int output',  @RecordCount output
		EXEC sp_executesql @PriorSQLCommand, N'@PriorRecordCount int output',  @PriorRecordCount output
		END TRY
		BEGIN CATCH
			-- Ignore error
		END CATCH
		
		UPDATE util.EdFiPopulation
		SET 
			RecordCount = @RecordCount,
			PriorRecordCount = @PriorRecordCount
		WHERE EdFiPopulationId = @EdFiPopulationId
		
		DELETE @EdFiPopulation
		WHERE EdFiPopulationId = @EdFiPopulationId
	END


	-----------------------------------
	-- Add summary to Comment
	-----------------------------------

	UPDATE util.EdFiPopulation
	SET PercentChanged = CAST(ISNULL((RecordCount - PriorRecordCount)*100.00/NULLIF(PriorRecordCount, 0), 0) as decimal(10,2))

	UPDATE util.EdFiPopulation
	SET Comment = 
		CASE
			WHEN PriorRecordCount = 0 AND RecordCount = 0 THEN '8 - No data'
			WHEN PriorRecordCount = 0 AND RecordCount > 0 THEN '4 - No prior data'
			WHEN PriorRecordCount > 0 AND RecordCount = 0 THEN '3 - No current data'
			WHEN RecordCount = PriorRecordCount AND RecordCount <> 0 THEN '7 - No change'		
			WHEN PercentChanged < -10 THEN '1 - Decreased by more than 10%'	
			WHEN PercentChanged BETWEEN -10 AND 0 THEN '5 - Decreased'		
			WHEN PercentChanged BETWEEN 0 AND 10 THEN '6 - Increased'
			WHEN PercentChanged > 10 THEN '2 - Increased by more than 10%'
			ELSE '0 - Unknown'
		END

	SET NOCOUNT OFF

END
--
--

GO
/****** Object:  StoredProcedure [util].[EdFiSanityCheck]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [util].[EdFiSanityCheck] (
	@EdFiSanityScript nvarchar(max) 
) AS
BEGIN

	SET NOCOUNT ON

	-----------------------------------
	-- Prep steps
	-----------------------------------

	EXEC util.DashboardAssociation

	DECLARE @SQLCommand nvarchar(4000)
	DECLARE @FileContent TABLE (FileContentId int identity(1, 1) primary key, Content nvarchar(MAX))
	DECLARE @EdFiSanityId int, @EndLine int, @InterChangeName nvarchar(255), @ExpectedResult nvarchar(255), @Description nvarchar(MAX), @Script nvarchar(MAX)
	DECLARE @Operator char(2), @ExpectedNumber float
	DECLARE @ActualResult TABLE (ActualResult nvarchar(MAX))

	TRUNCATE TABLE util.EdFiSanity
	
	-----------------------------------
	-- Import the script file to a table
	-----------------------------------

	INSERT INTO @FileContent(Content)
	SELECT REPLACE(Token, CHAR(13), '')
	FROM util.Split(@EdFiSanityScript, CHAR(10))
	ORDER BY Id	
				
	IF (SELECT COUNT(1) FROM @FileContent WHERE LEN(LTRIM(RTRIM(Content))) > 0) = 0
	BEGIN
		INSERT INTO util.EdFiSanity
		SELECT 0, 0, '', 'Failed', 'Make sure that the EdFiSanity.txt file exists', '', '', '', '', NULL, 1, 1
	END


	INSERT INTO util.EdFiSanity(BeginLine)
	SELECT FileContentId
	FROM @FileContent
	WHERE Content LIKE '--%Interchange:%'

	UPDATE a
	SET EndLine = ISNULL(b.BeginLine - 1, (SELECT MAX(FileContentId) FROM @FileContent))
	FROM 
		util.EdFiSanity a LEFT OUTER JOIN
		util.EdFiSanity b
			ON a.EdFiSanityId = b.EdFiSanityId - 1

	
	-----------------------------------
	-- Parse the script file
	-----------------------------------

	WHILE EXISTS (SELECT 1 FROM util.EdFiSanity WHERE ParserCompletionFlag = 0)
	BEGIN
		SELECT 
			@EdFiSanityId = EdFiSanityId,
			@EndLine = -1,
			@InterChangeName = '',
			@ExpectedResult = '',
			@Description = '',
			@Script = '',
			@Operator = '',
			@ExpectedNumber = NULL
		FROM util.EdFiSanity 
		WHERE ParserCompletionFlag = 0
		ORDER BY EdFiSanityId
		
		SELECT 
			@InterChangeName	= MAX(LTRIM(RTRIM(REPLACE(CASE WHEN b.Content LIKE '-- Interchange:%' THEN b.Content END, '-- Interchange:', '')))),
			@ExpectedResult		= MAX(LTRIM(RTRIM(REPLACE(CASE WHEN b.Content LIKE '-- ExpectedResult:%' THEN b.Content END, '-- ExpectedResult:', '')))),
			@Description		= MAX(LTRIM(RTRIM(REPLACE(CASE WHEN b.Content LIKE '-- Description:%' THEN b.Content END, '-- Description:', ''))))
		FROM 
			util.EdFiSanity a INNER JOIN
			@FileContent b
				ON b.FileContentId BETWEEN a.BeginLine AND a.EndLine
		WHERE a.EdFiSanityId = @EdFiSanityId
		GROUP BY a.EdFiSanityId

		SELECT @Script = @Script + ' ' + ISNULL(b.Content, '')
		FROM 
			util.EdFiSanity a INNER JOIN
			@FileContent b
				ON b.FileContentId BETWEEN a.BeginLine AND a.EndLine
		WHERE b.Content NOT LIKE '%--%'
		AND a.EdFiSanityId = @EdFiSanityId

		-- @ExpectedNumber will remain NULL if the expected result is not number
		BEGIN TRY
			IF LEFT(LTRIM(@ExpectedResult), 1) IN ('<', '>')
				SELECT @ExpectedNumber = CAST(REPLACE(REPLACE(REPLACE(@ExpectedResult, '<', ''), '>', ''), '=', '') as float)
		END TRY
		BEGIN CATCH
		END CATCH

		UPDATE util.EdFiSanity
		SET	
			ParserCompletionFlag = 1,
			InterChangeName = @InterChangeName,
			ExpectedResult = @ExpectedResult,
			[Description] = @Description,
			Script = @Script,
			ExpectedNumber = @ExpectedNumber,
			Operator = REPLACE(REPLACE(@ExpectedResult, CAST(@ExpectedNumber as varchar), ''), ' ', '')
		WHERE EdFiSanityId = @EdFiSanityId

	END



	-----------------------------------
	-- Loop through the EdFiSanity and execute the query
	-----------------------------------

	WHILE EXISTS (SELECT 1 FROM util.EdFiSanity WHERE ExecCompletionFlag = 0)
	BEGIN
		SELECT 
			@EdFiSanityId = EdFiSanityId,
			@Script = Script
		FROM util.EdFiSanity 
		WHERE ExecCompletionFlag = 0
		ORDER BY EdFiSanityId
		
		DELETE @ActualResult

		BEGIN TRY
			INSERT INTO @ActualResult(ActualResult)
			EXEC sp_executesql @Script
		END TRY
		BEGIN CATCH
			INSERT INTO @ActualResult(ActualResult)
			SELECT 'Error: ' + ERROR_MESSAGE()
		END CATCH

		UPDATE util.EdFiSanity
		SET 
			ExecCompletionFlag = 1,
			ActualResult = (SELECT MAX(ActualResult) FROM @ActualResult)
		WHERE EdFiSanityId = @EdFiSanityId

	END



	-----------------------------------
	-- Evaluation (Passed/Failed)
	-----------------------------------

	-- Evaluation for numeric results
	UPDATE util.EdFiSanity
	SET ScriptResult =
		CASE Operator
			WHEN '>'  THEN CASE WHEN CAST(ActualResult as float) >  ExpectedNumber THEN 'Passed' ELSE 'Failed' END
			WHEN '<'  THEN CASE WHEN CAST(ActualResult as float) <  ExpectedNumber THEN 'Passed' ELSE 'Failed' END
			WHEN '>=' THEN CASE WHEN CAST(ActualResult as float) >= ExpectedNumber THEN 'Passed' ELSE 'Failed' END
			WHEN '<=' THEN CASE WHEN CAST(ActualResult as float) <= ExpectedNumber THEN 'Passed' ELSE 'Failed' END
		END
	WHERE ExpectedNumber IS NOT NULL

	-- Evaluation for empty results	
	UPDATE util.EdFiSanity
	SET ScriptResult = CASE WHEN ActualResult = '' THEN 'Passed' ELSE 'Failed' END
	FROM util.EdFiSanity
	WHERE ExpectedResult IN ('<empty>', '')

	-- This evaluates everything else
	UPDATE util.EdFiSanity
	SET ScriptResult = CASE WHEN ActualResult = ExpectedResult THEN 'Passed' ELSE 'Failed' END
	FROM util.EdFiSanity
	WHERE ScriptResult IS NULL


	-- Remove synonym to objects in the Dashboard database
	EXEC util.DashboardAssociation 0		

	SET NOCOUNT OFF

END
--
--

GO
/****** Object:  StoredProcedure [util].[TeamCityIntegration]    Script Date: 9/24/2015 11:35:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- OutputOption: EdFiException, EdFiPopulation, EdFiSanityCheck, TeamCityStatistic
CREATE PROCEDURE [util].[TeamCityIntegration] (
	@OutputOption nvarchar(255)
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OutputTable TABLE (
		OutputId		int identity(1,1) primary key,
		OutputOption	nvarchar(255) not null,
		OutputIndex		nvarchar(3) default '', 
		OutputText		nvarchar(MAX)
	)

	-----------------------------------
	-- Export the main report and top 100 records for each EdFiException group
	-----------------------------------

	IF @OutputOption = 'EdFiException'
	BEGIN
		DELETE @OutputTable

		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EdFiException' AND TABLE_SCHEMA = 'edfi')
		BEGIN
			DECLARE @EdFiExceptionTable TABLE (
				EdFiExceptionTableId	int identity(1,1) primary key,
				ExceptionLevel			nvarchar(20), 
				ErrorMessage			nvarchar(MAX), 
				TableName				nvarchar(255), 
				PackageName				nvarchar(255),
				RecordCount				int,
				CompletionFlag			bit
			)
			
			INSERT INTO @EdFiExceptionTable
			SELECT ExceptionLevel, ErrorMessage, TableName, PackageName, COUNT(1) as RecordCount, 0 as CompletionFlag
			FROM edfi.EdFiException WITH (NOLOCK)
			GROUP BY ExceptionLevel, ErrorMessage, TableName, PackageName
			ORDER BY MIN(StartTime)

			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '<html><body>'
			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '<h3>EdFiException Summary</h3><table border="1" cellpadding="3" cellspacing="0"><tr><th>Package Name</th><th>Table Name</th><th>Exception Level</th><th>Error Message</th><th>Record Count</th></tr>'

			INSERT INTO @OutputTable(OutputOption, OutputText)
			SELECT @OutputOption, '<tr>' +
				'<td>' + ISNULL(PackageName, 'Unknown') + '</td>' +
				'<td>' + ISNULL(TableName, 'Unknown') + '</td>' +
				'<td>' + ISNULL(ExceptionLevel, 'Unknown') + '</td>' +
				'<td><a href = "EdFiException' + CAST(EdFiExceptionTableId as nvarchar) + '.html">' + ISNULL(ErrorMessage, 'Unknown') + '</a></td>' +
				'<td align="right">' + REPLACE(CONVERT(nvarchar, CAST(RecordCount as money), 1), '.00', '') + '</td>' +
				'</tr>'
			FROM @EdFiExceptionTable
			ORDER BY ExceptionLevel, RecordCount DESC

			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '</table><br/><br/><br/>'
			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '</body></html>'


			DECLARE @EdFiExceptionTableId int, @ExceptionLevel nvarchar(20), @ErrorMessage nvarchar(MAX), @TableName nvarchar(255), @PackageName nvarchar(255), @RecordCount int
			WHILE EXISTS (SELECT 1 FROM @EdFiExceptionTable WHERE CompletionFlag = 0)
			BEGIN
				SELECT
					@EdFiExceptionTableId = EdFiExceptionTableId,
					@ExceptionLevel = ISNULL(ExceptionLevel, 'Unknown'),
					@ErrorMessage = ISNULL(ErrorMessage, 'Unknown'),
					@TableName = ISNULL(TableName, 'Unknown'),
					@PackageName = ISNULL(PackageName, 'Unknown'),
					@RecordCount = RecordCount
				FROM @EdFiExceptionTable
				WHERE CompletionFlag = 0
				ORDER BY EdFiExceptionTableId
				
				INSERT INTO @OutputTable(OutputOption, OutputIndex, OutputText) SELECT @OutputOption, @EdFiExceptionTableId, '<html><body>'
				INSERT INTO @OutputTable(OutputOption, OutputIndex, OutputText) SELECT @OutputOption, @EdFiExceptionTableId, '<h3>EdFiException Sample' + CASE WHEN @RecordCount > 100 THEN ' (top 100 records)' ELSE '' END + '</h3>'			
				INSERT INTO @OutputTable(OutputOption, OutputIndex, OutputText) SELECT @OutputOption, @EdFiExceptionTableId, '<b>ErrorMessage:</b> ' + @ErrorMessage + '<br>'
				INSERT INTO @OutputTable(OutputOption, OutputIndex, OutputText) SELECT @OutputOption, @EdFiExceptionTableId, '<b>TableName:</b> ' + @TableName + '<br>'
				
				INSERT INTO @OutputTable(OutputOption, OutputIndex, OutputText)
				SELECT TOP 1 @OutputOption, @EdFiExceptionTableId, '<b>ColumnNameList:</b> ' + ISNULL(ColumnNameList, 'Unknown') + '<br><br>'
				FROM edfi.EdFiException WITH (NOLOCK)
				WHERE ExceptionLevel = @ExceptionLevel
				AND ErrorMessage = @ErrorMessage
				AND TableName = @TableName
				AND PackageName = @PackageName

				INSERT INTO @OutputTable(OutputOption, OutputIndex, OutputText) SELECT @OutputOption, @EdFiExceptionTableId, '<table border="1" cellpadding="3" cellspacing="0"><tr><th>ColumnValueList</th><th>IdentifierCondition</th><th>LookupCondition</th></tr>'

				INSERT INTO @OutputTable(OutputOption, OutputIndex, OutputText)
				SELECT TOP 100 @OutputOption, @EdFiExceptionTableId, '<tr>' +
					'<td>' + ISNULL(ColumnValueList, 'Unknown') + '</td>' +
					'<td>' + ISNULL(NULLIF(IdentifierCondition, ''), '&nbsp;') + '</td>' +
					'<td>' + ISNULL(NULLIF(LookupCondition, ''), '&nbsp;') + '</td>' +
					'</tr>'
				FROM edfi.EdFiException WITH (NOLOCK)
				WHERE ExceptionLevel = @ExceptionLevel
				AND ErrorMessage = @ErrorMessage
				AND TableName = @TableName
				AND PackageName = @PackageName

				INSERT INTO @OutputTable(OutputOption, OutputIndex, OutputText) SELECT @OutputOption, @EdFiExceptionTableId, '</table>'
				INSERT INTO @OutputTable(OutputOption, OutputIndex, OutputText) SELECT @OutputOption, @EdFiExceptionTableId, '</body></html>'
			
				UPDATE @EdFiExceptionTable 
				SET CompletionFlag = 1
				WHERE EdFiExceptionTableId = @EdFiExceptionTableId
			END
		END		
	END


	-----------------------------------
	-- Reports for EdFiPopulation
	-----------------------------------

	IF @OutputOption = 'EdFiPopulation'	
	BEGIN
		DELETE @OutputTable

		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EdFiPopulation' AND TABLE_SCHEMA = 'util')
		BEGIN
			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '<html><body>'
			
			INSERT INTO @OutputTable(OutputOption, OutputText)
			SELECT @OutputOption, '<table border="1" cellpadding="3" cellspacing="0">' + 
				'<tr><th>Environment</th><th>Database Name</th><th>Max Attendance Date</th></tr>' +
				'<tr><td>New Build</td><td>' + ISNULL((SELECT TOP 1 DatabaseName FROM util.EdFiPopulation), 'Unknown') + '</td><td>' + ISNULL(CAST((SELECT TOP 1 MostRecentDate FROM util.EdFiPopulation WITH (NOLOCK)) as varchar), 'Unknown') + '</td></tr>' +
				'<tr><td>Referenced Build</td><td>' + ISNULL((SELECT TOP 1 PriorDatabaseName FROM util.EdFiPopulation), 'Unknown') + '</td><td>' + ISNULL(CAST((SELECT TOP 1 PriorMostRecentDate FROM util.EdFiPopulation WITH (NOLOCK)) as varchar), 'Unknown') + '</td></tr>' +
				'</table><br>'

			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '<h3>EdFi Population Summary</h3><table border="1" cellpadding="3" cellspacing="0"><tr><th>Schema</th><th>Table Name</th><th>Record Count</th><th>Prior Count</th><th>Percent Changed</th><th>Comment</th></tr>'

			INSERT INTO @OutputTable(OutputOption, OutputText)
			SELECT @OutputOption, '<tr>' +
				'<td>' + TableSchema + '</td>' +
				'<td>' + TableName + '</td>' +
				'<td align="right">' + REPLACE(CONVERT(nvarchar, CAST(RecordCount as money), 1), '.00', '') + '</td>' +
				'<td align="right">' + REPLACE(CONVERT(nvarchar, CAST(PriorRecordCount as money), 1), '.00', '') + '</td>' +
				'<td align="right">' + CAST(PercentChanged as varchar) + '%</td>' +
				'<td>' + CASE WHEN LEFT(Comment, 1) IN (1, 2) THEN '<font color="red">' + Comment + '</font>' ELSE Comment END + '</td>' +
				'</tr>'
			FROM util.EdFiPopulation WITH (NOLOCK)
			ORDER BY Comment, TableSchema, TableName
			
			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '</table><br/><br/><br/>'
			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '</body></html>'
		END
	END


	-----------------------------------
	-- Reports for EdFiSanityCheck
	-----------------------------------

	IF @OutputOption = 'EdFiSanityCheck'
	BEGIN
		DELETE @OutputTable
		
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EdFiSanity' AND TABLE_SCHEMA = 'util')
		BEGIN
			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '<html><body>'
			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, 'Number of scripts: ' + CAST(ISNULL((SELECT COUNT(1) FROM util.EdFiSanity WITH (NOLOCK)), 0) as nvarchar) + '<br><br>'
			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '<table border="1" cellpadding="3" cellspacing="0"><tr><th>InterChange</th><th>Description</th><th>Result</th><th>Expected Result</th><th>Actual Result</th><th>Script</th></tr>'

			INSERT INTO @OutputTable(OutputOption, OutputText)
			SELECT @OutputOption, '<tr>' + 
				'<td valign="top">' + InterChangeName + '</td>' +
				'<td valign="top">' + [Description] + '</td>' +
				'<td valign="top">' + CASE ScriptResult WHEN 'Failed' THEN '<font color="red">' + ScriptResult + '</font>' ELSE ScriptResult END + '</td>' +
				'<td valign="top" width="200">' + ISNULL(NULLIF(ExpectedResult, ''), '&nbsp;') + '</td>' + 
				'<td valign="top" width="200">' + ISNULL(NULLIF(ActualResult, ''), '&nbsp;') + '</td>' + 
				'<td valign="top"><font size="-2">' + Script + '</font></td>' +
				'</tr>'
			FROM util.EdFiSanity WITH (NOLOCK)
			ORDER BY InterchangeName, ScriptResult

			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '</table><br/><br/><br/>'
			INSERT INTO @OutputTable(OutputOption, OutputText) SELECT @OutputOption, '</body></html>'
		END
	END


	-----------------------------------
	-- Publish stats to TeamCity
	-----------------------------------
	
	IF @OutputOption = 'TeamCityStatistic'
	BEGIN
		DELETE @OutputTable
		
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'QAResults' AND TABLE_SCHEMA = 'util')
			INSERT INTO util.TeamCityStatistic(StatisticKey, StatisticValue)
			SELECT 'FailedQAScripts', CAST(COUNT(1) as nvarchar) FROM util.QAResults WITH (NOLOCK) WHERE ScriptResult = 'Failed'
		
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EdFiSanity' AND TABLE_SCHEMA = 'util')
			INSERT INTO util.TeamCityStatistic(StatisticKey, StatisticValue)
			SELECT 'FailedSanityCheck', CAST(COUNT(1) as nvarchar) FROM util.EdFiSanity WITH (NOLOCK) WHERE ScriptResult = 'Failed'

		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EdFiException' AND TABLE_SCHEMA = 'edfi')
		BEGIN
			INSERT INTO util.TeamCityStatistic(StatisticKey, StatisticValue)
			SELECT 'EdFiExceptionErrors', CAST(COUNT(1) as nvarchar) FROM edfi.EdFiException WITH (NOLOCK) WHERE ExceptionLevel = 'Error'

			INSERT INTO util.TeamCityStatistic(StatisticKey, StatisticValue)
			SELECT 'EdFiExceptionWarnings', CAST(COUNT(1) as nvarchar) FROM edfi.EdFiException WITH (NOLOCK) WHERE ExceptionLevel = 'Warning'

			INSERT INTO util.TeamCityStatistic(StatisticKey, StatisticValue)
			SELECT 'EdFiExceptionEntityNotFounds', CAST(COUNT(1) as nvarchar) FROM edfi.EdFiException WITH (NOLOCK) WHERE ExceptionLevel = 'EntityNotFound'
		END

		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EdFiException' AND TABLE_SCHEMA = 'edfi')
		AND EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EdFiPopulation' AND TABLE_SCHEMA = 'util')
			INSERT INTO util.TeamCityStatistic(StatisticKey, StatisticValue)
			SELECT 'EdFiExceptionMaxErrorRate', CAST(MAX(CAST(ErrorRate as decimal(10, 2))) as nvarchar)
			FROM (
				SELECT a.TableName, ISNULL(COUNT(1)*100.00/NULLIF(b.RecordCount, 0), 100) as ErrorRate
				FROM 
					edfi.EdFiException a WITH (NOLOCK) LEFT OUTER JOIN
					util.EdFiPopulation b WITH (NOLOCK)
						ON a.TableName = b.TableSchema + '.' + b.TableName
				WHERE a.ErrorCode <> -1071607778
				AND a.ErrorMessage NOT LIKE '%Cannot insert duplicate key in object%'
				GROUP BY a.TableName, b.RecordCount
			) as temp

			
		DELETE @OutputTable
		
		INSERT INTO @OutputTable(OutputOption, OutputText)
		SELECT @OutputOption, '##teamcity[buildStatisticValue key=''' + StatisticKey + ''' value=''' + ISNULL(StatisticValue, 0) + ''']'
		FROM util.TeamCityStatistic
	END



	-----------------------------------
	-- Print out reports 
	-----------------------------------

	IF @OutputOption <> 'TeamCityStatistic'
	BEGIN
		SELECT
			'FileName=' + OutputOption + ISNULL(OutputIndex, '') + '.html',
			    OutputText,
				OutputId
				FROM @OutputTable 
				ORDER BY OutputOption, OutputIndex, OutputId
	END
	ELSE
	BEGIN
		-- (Powershell will simply Out-Host the data to build log)
		SELECT OutputText
		FROM @OutputTable
	END
	
	SET NOCOUNT OFF

END
--
--

GO
EXEC sys.sp_addextendedproperty @name=N'microsoft_database_tools_support', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysdiagrams'
GO
USE [master]
GO
ALTER DATABASE [easol_test] SET  READ_WRITE 
GO
