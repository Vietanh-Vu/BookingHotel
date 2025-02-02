USE [master]
GO
/****** Object:  Database [BookingHotel]    Script Date: 12/10/2023 1:40:56 AM ******/
CREATE DATABASE [BookingHotel]
--  CONTAINMENT = NONE
--  ON  PRIMARY 
-- ( NAME = N'BookingHotel', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\BookingHotel.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
--  LOG ON 
-- ( NAME = N'BookingHotel_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\BookingHotel_0.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
--  WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
-- GO
ALTER DATABASE [BookingHotel] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BookingHotel].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BookingHotel] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BookingHotel] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BookingHotel] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BookingHotel] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BookingHotel] SET ARITHABORT OFF 
GO
ALTER DATABASE [BookingHotel] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BookingHotel] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BookingHotel] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BookingHotel] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BookingHotel] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BookingHotel] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BookingHotel] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BookingHotel] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BookingHotel] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BookingHotel] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BookingHotel] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BookingHotel] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BookingHotel] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BookingHotel] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BookingHotel] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BookingHotel] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BookingHotel] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BookingHotel] SET RECOVERY FULL 
GO
ALTER DATABASE [BookingHotel] SET  MULTI_USER 
GO
ALTER DATABASE [BookingHotel] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BookingHotel] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BookingHotel] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BookingHotel] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BookingHotel] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BookingHotel] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [BookingHotel] SET QUERY_STORE = ON
GO
ALTER DATABASE [BookingHotel] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [BookingHotel]
GO
/****** Object:  UserDefinedFunction [dbo].[GetCumulativeUsersByMonth]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM dbo.GetOLDUsersLastMonth()

--8.---------Tổng users ĐẾN TỪNG tháng của hệ thống khách sạn TRONG 12 THÁNG GẦN NHẤT 
-- OUTPUT : TỔNG USERS(GUEST) ĐẾN ĐẶT PHÒNG TRONG 12 THÁNG 
-- Cụ thể : Month(int), NumberofUsers(int)

CREATE FUNCTION [dbo].[GetCumulativeUsersByMonth]()
RETURNS @Result TABLE
(
    [Month] INT,
    [Year] INT,
    UsersCount INT
)
AS
BEGIN
    INSERT INTO @Result ([Month], [Year], UsersCount)
    SELECT
        MONTH(StartDate) AS [Month],
        YEAR(StartDate) AS [Year],
        SUM(COUNT(DISTINCT UsersId)) OVER (ORDER BY YEAR(StartDate), MONTH(StartDate)) AS CumulativeUsers
    FROM
        Reservation
    GROUP BY
        YEAR(StartDate), MONTH(StartDate)
    ORDER BY
        YEAR(StartDate), MONTH(StartDate);

    RETURN;
END;

GO
/****** Object:  Table [dbo].[Reservation]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reservation](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReservationId]  AS ('RV'+right('0'+CONVERT([varchar](4),[ID]),(5))) PERSISTED NOT NULL,
	[UsersId] [varchar](7) NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[TsCreated] [datetime] NOT NULL,
	[TsUpdated] [datetime] NOT NULL,
	[DiscountPercent] [decimal](5, 2) NULL,
	[TotalPrice] [decimal](10, 2) NULL,
 CONSTRAINT [PK_Reservation] PRIMARY KEY CLUSTERED 
(
	[ReservationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[Doanhthu_12_LATEST_MONTHS]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--######################### FUNCTION ###############################

--1.--------------- Doanh thu 12 tháng GẦN NHẤT của cả hệ thống
-- OUTPUT : DOANH THU 12 THÁNG CỦA CẢ HỆ THỐNG KHÁCH SẠN
-- Cụ thể: Month(int), Income

-- DROP FUNCTION Doanhthu_12_LATEST_MONTHS
CREATE FUNCTION [dbo].[Doanhthu_12_LATEST_MONTHS] ()
RETURNS TABLE 
AS
RETURN 
(
    SELECT 
        MONTH(EndDate) AS [MONTH],
        YEAR(EndDate) AS [YEAR],
        SUM(TotalPrice) AS REVENUE 
    FROM Reservation 
    WHERE EndDate >= DATEADD(MONTH, -12, '2023-07-01') 
    GROUP BY 
        MONTH(EndDate),
        YEAR(EndDate)
);

GO
/****** Object:  Table [dbo].[Category]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryId]  AS ('CA'+right('0'+CONVERT([varchar](3),[ID]),(3))) PERSISTED NOT NULL,
	[CategoryName] [varchar](128) NOT NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Hotel]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hotel](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[HotelId]  AS ('HO'+right('0'+CONVERT([varchar](4),[ID]),(5))) PERSISTED NOT NULL,
	[CategoryId] [varchar](5) NULL,
	[HotelName] [varchar](128) NOT NULL,
	[IsActive] [bit] NULL,
	[Address] [text] NOT NULL,
	[HotelImg] [varchar](128) NULL,
	[Description] [varchar](max) NULL,
 CONSTRAINT [PK_Hotel] PRIMARY KEY CLUSTERED 
(
	[HotelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Room]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Room](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RoomId]  AS ('RO'+right('0'+CONVERT([varchar](4),[ID]),(5))) PERSISTED NOT NULL,
	[HotelId] [varchar](7) NULL,
	[RoomTypeId] [varchar](5) NULL,
	[RoomName] [varchar](128) NOT NULL,
	[CurrentPrice] [decimal](10, 2) NOT NULL,
	[IsAvailable] [bit] NULL,
	[IsActive] [bit] NULL,
	[Description] [varchar](max) NULL,
 CONSTRAINT [PK_Room] PRIMARY KEY CLUSTERED 
(
	[RoomId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoomReserved]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomReserved](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RoomReservedId]  AS ('RR'+right('0'+CONVERT([varchar](5),[ID]),(6))) PERSISTED NOT NULL,
	[ReservationID] [varchar](7) NULL,
	[RoomId] [varchar](7) NULL,
 CONSTRAINT [PK_RoomReserved] PRIMARY KEY CLUSTERED 
(
	[RoomReservedId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[Doanhthu_CA_LATEST_MONTH]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT * FROM dbo.Doanhthu_12_LATEST_MONTHS() AS DOANHTHU ORDER BY REVENUE

--2.--------------- Doanh thu 1 tháng GẦN NHẤT của từng loại khách sạn
-- OUTPUT : DOANH THU 1 THÁNG GẦN NHẤT CỦA TỪNG LOẠI KHÁCH SẠN
-- Cụ thể: Month(int), Income

-- DROP FUNCTION Doanhthu_CA_LATEST_MONTH
CREATE FUNCTION [dbo].[Doanhthu_CA_LATEST_MONTH]
()
RETURNS TABLE
AS
RETURN
(
  SELECT
    Category.CategoryName, Category.CategoryId,
    SUM(TotalPrice) AS Income
  FROM
    Reservation
    JOIN RoomReserved ON Reservation.ReservationId = RoomReserved.ReservationID
    JOIN Room ON Room.RoomId = RoomReserved.RoomId
    JOIN Hotel ON Hotel.HotelId = Room.HotelId
    JOIN Category ON Category.CategoryId = Hotel.CategoryId
  WHERE
    EndDate >= DATEADD(MONTH, -1, '2023-07-01') 
  GROUP BY
    Category.CategoryName, Category.CategoryId
);

GO
/****** Object:  UserDefinedFunction [dbo].[Doanhthu_Hotel_12months]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT * FROM dbo.Doanhthu_CA_LATEST_MONTH() 

--3.------------- Doanh thu của một khách sạn trong 12 tháng gần nhất
-- INPUT: HOTELID
-- OUTPUT: TÊN KHÁCH SẠN(VARCHAR),THÁNG(INT), Năm(int),INCOME(INT)

-- drop function Doanhthu_Hotel_12months
CREATE FUNCTION [dbo].[Doanhthu_Hotel_12months]
(@HID VARCHAR(7))
RETURNS TABLE
AS
  RETURN (SELECT Hotel.HotelName ,MONTH(EndDate) AS [MONTH], YEAR(EndDate) AS [YEAR],SUM(TotalPrice) AS INCOME
  FROM Reservation
  JOIN RoomReserved ON Reservation.ReservationId = RoomReserved.ReservationID
  JOIN Room ON Room.RoomId = RoomReserved.RoomId
  JOIN Hotel ON Hotel.HotelId = Room.HotelId
  WHERE EndDate >= DATEADD(MONTH, -12, '2023-07-01') AND Hotel.HotelId = @HID
  GROUP BY Hotel.HotelName, MONTH(EndDate), YEAR(EndDate) 
);

GO
/****** Object:  Table [dbo].[RoomType]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RoomTypeId]  AS ('RT'+right('0'+CONVERT([varchar](3),[ID]),(3))) PERSISTED NOT NULL,
	[RoomTypeName] [varchar](128) NOT NULL,
 CONSTRAINT [PK_RoomType] PRIMARY KEY CLUSTERED 
(
	[RoomTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[Doanhthu_ALL_RT_1month]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM dbo.Doanhthu_Hotel_12months('HO01') ORDER BY MONTH

--4. Liệt kê doanh thu các loại phòng trong 1 THÁNG GẦN NHẤT
-- INPUT: NULL
-- OUTPUT: YEAR, ROOMTYPENAME, INCOME

-- DROP FUNCTION Doanhthu_ALL_RT_1month
CREATE FUNCTION [dbo].[Doanhthu_ALL_RT_1month]
()
RETURNS TABLE
AS
  RETURN (SELECT MONTH(EndDate) AS MONTH ,YEAR(EndDate) AS YEAR, RoomType.RoomTypeName, SUM(TotalPrice) AS Doanhthu
  FROM Reservation
  JOIN RoomReserved ON Reservation.ReservationId = RoomReserved.ReservationID
  JOIN Room ON Room.RoomId = RoomReserved.RoomId
  JOIN RoomType ON RoomType.RoomTypeId = Room.RoomTypeId
  WHERE EndDate >= DATEADD(MONTH, -1, '2023-07-01')
  GROUP BY RoomType.RoomTypeName,MONTH(EndDate) ,YEAR(EndDate));


GO
/****** Object:  Table [dbo].[Users]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UsersId]  AS ('US'+right('0'+CONVERT([varchar](4),[ID]),(5))) PERSISTED NOT NULL,
	[FirstName] [varchar](128) NOT NULL,
	[LastName] [varchar](128) NOT NULL,
	[Email] [varchar](255) NOT NULL,
	[Phone] [varchar](255) NOT NULL,
	[Address] [varchar](255) NOT NULL,
	[IsAdmin] [bit] NULL,
	[Password] [varchar](128) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[UsersId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[USERS_12months]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM dbo.Doanhthu_ALL_RT_1month()

--5.---------Tổng users theo tháng của hệ thống khách sạn TRONG 12 THÁNG GẦN NHẤT
-- INPUT : 
-- OUTPUT : TỔNG USERS(GUEST) ĐẾN ĐẶT PHÒNG TRONG 12 THÁNG 
-- Cụ thể : Month(int), NumberofUsers(int)

-- DROP FUNCTION USERS_12months
CREATE FUNCTION [dbo].[USERS_12months]
()
RETURNS TABLE
AS
  RETURN (SELECT  MONTH(EndDate) AS Month, YEAR(EndDate) AS Year , COUNT(Users.ID) AS NumberofUsers
  FROM Users
  JOIN Reservation ON Reservation.UsersId = Users.UsersId 
  WHERE EndDate >= DATEADD(MONTH, -12,'2023-07-01')
  GROUP BY MONTH(EndDate), YEAR(EndDate));

GO
/****** Object:  UserDefinedFunction [dbo].[GetNewUsersLastMonth]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT * FROM dbo.USERS_12months() ORDER BY NumberofUsers

----------------------------------------------------
--6. ----------------Tổng user mới nhất tháng trước
-- OUTPUT: hotelname, new_users
-- DROP FUNCTION GetNewUsersLastMonth
CREATE FUNCTION [dbo].[GetNewUsersLastMonth]()
RETURNS TABLE
AS
    -- Truy vấn để tính số người dùng mới của tháng gần nhất
    RETURN (
        SELECT COUNT(DISTINCT Reservation.UsersId) AS New_Users
        FROM Reservation 
		JOIN RoomReserved ON Reservation.ReservationId = RoomReserved.ReservationID
		JOIN Room ON Room.RoomId = RoomReserved.RoomId
		JOIN Hotel ON Hotel.HotelId = Room.HotelId
        WHERE 
		StartDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, '2023-07-01') - 1, 0)
		AND Reservation.UsersId NOT IN (
            SELECT DISTINCT UsersId
            FROM Reservation
            WHERE StartDate < (DATEADD(MONTH, DATEDIFF(MONTH, 0, '2023-07-01') - 1, 0))
        )

	);

GO
/****** Object:  UserDefinedFunction [dbo].[GetOLDUsersLastMonth]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SELECT * FROM dbo.GetNewUsersLastMonth()

	
-----------------------------------------------------
--7.------------Tổng user cũ nhất tháng trước
-- OUTPUT: hotelname, old_users
-- DROP FUNCTION GetOLDUsersLastMonth
CREATE FUNCTION [dbo].[GetOLDUsersLastMonth]()
RETURNS TABLE
AS
    -- Truy vấn để tính số người dùng mới của tháng gần nhất
    RETURN (    SELECT COUNT(DISTINCT Reservation.UsersId) AS Old_Users
        FROM Reservation 
		JOIN RoomReserved ON Reservation.ReservationId = RoomReserved.ReservationID
		JOIN Room ON Room.RoomId = RoomReserved.RoomId
		JOIN Hotel ON Hotel.HotelId = Room.HotelId
        WHERE 
		StartDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, '2023-07-01') - 1, 0)
		AND Reservation.UsersId IN (
            SELECT DISTINCT UsersId
            FROM Reservation
            WHERE StartDate < (DATEADD(MONTH, DATEDIFF(MONTH, 0, '2023-07-01') - 1, 0))
        )
	);

GO
/****** Object:  Table [dbo].[ReservationStatus]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RSId]  AS ('RS'+right('0'+CONVERT([varchar](3),[ID]),(3))) PERSISTED NOT NULL,
	[StatusName] [varchar](128) NOT NULL,
 CONSTRAINT [PK_ReservationStatus] PRIMARY KEY CLUSTERED 
(
	[RSId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReservationStatusEvents]    Script Date: 12/10/2023 1:40:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationStatusEvents](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RSEId]  AS ('RE'+right('0'+CONVERT([varchar](4),[ID]),(5))) PERSISTED NOT NULL,
	[RSETsCreated] [datetime] NOT NULL,
	[Details] [text] NOT NULL,
	[RSId] [varchar](5) NULL,
	[ReservationId] [varchar](7) NULL,
 CONSTRAINT [PK_RSE] PRIMARY KEY CLUSTERED 
(
	[RSEId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Category] ON 

INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (1, N'Luxury')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (10, N'Beachfront')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (11, N'Mountain Lodge')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (12, N'Historic')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (13, N'Family-Friendly')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (14, N'Pet-Friendly')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (15, N'Eco-Friendly')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (2, N'Boutique')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (3, N'Budget')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (4, N'Resort')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (5, N'Extended Stay')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (6, N'Business')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (7, N'Bed and Breakfast')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (8, N'All-Inclusive Resort')
INSERT [dbo].[Category] ([ID], [CategoryName]) VALUES (9, N'Spa and Wellness')
SET IDENTITY_INSERT [dbo].[Category] OFF
GO
SET IDENTITY_INSERT [dbo].[Hotel] ON 

INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (1, N'CA01', N'Grand Luxury Hotel', 1, N'123 Main Street, City', N'663504d4-6d0c-482d-a133-a7071aec7e92.jpg', N'A luxurious hotel offering world-class amenities.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (10, N'CA010', N'Pet-Friendly Haven', 1, N'567 Pet Street, City', N'c5353466-c2d2-40a5-adad-8a42569f4ad5.jpg', N'A hotel that warmly welcomes guests and their furry friends.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (11, N'CA011', N'Urban Loft Hotel', 1, N'321 Loft Avenue, City', N'7591f246-49a9-4f7a-9635-b07888e807ac.jpg', N'A trendy hotel offering stylish loft-style accommodations.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (12, N'CA012', N'Seaside Escape Resort', 1, N'888 Sea View Drive, City', N'f96ed4ff-95f9-4974-948c-c0353c19bb58.jpg', N'A resort situated by the ocean, perfect for relaxation.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (13, N'CA013', N'Wellness Retreat Spa Hotel', 1, N'555 Serenity Road, City', N'828633cf-39a5-47f2-9029-4335f49ba128.jpg', N'A hotel dedicated to providing rejuvenating spa experiences.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (14, N'CA014', N'Eco-Friendly Lodge', 1, N'66 Green Lane, City', N'4555e0eb-be21-426a-939c-273acaa9ee62.jpg', N'An environmentally conscious hotel in harmony with nature.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (15, N'CA015', N'Modern City Hotel', 1, N'777 Urban Street, City', N'58f16524-8848-4690-b7d2-e1eeae30fd9a.jpg', N'A sleek and contemporary hotel in the heart of the city.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (16, N'CA01', N'Azure Heights Hotel', 1, N'123 Main Street, City', N'b83bb62e-c43c-4eb0-b6d8-dfbdcd2b8317.jpg', N'A luxurious hotel with breathtaking views.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (17, N'CA02', N'Radiant Oasis Inn', 1, N'456 Sunshine Avenue, City', N'4f606b35-6a70-41e8-8c54-d1dec067c17d.jpg', N'An oasis of tranquility in the heart of the city.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (18, N'CA03', N'Enigma Lodge', 1, N'789 Mystery Lane, City', N'cda40bdc-ff89-4cb9-ba2f-c7bb85f78c85.jpg', N'A place where mystery and comfort meet.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (19, N'CA04', N'Velvet Sky Retreat', 1, N'10 Serenity Road, City', N'71cc700e-9b50-4660-89ba-28e6b253fae0.jpg', N'Indulge in luxury beneath the velvet sky.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (2, N'CA02', N'Cozy Boutique Hotel', 1, N'456 Elm Street, City', N'9ae8f1ba-d9f2-413a-b613-f1089de9d7d9.jpg', N'A charming boutique hotel with a warm and inviting ambiance.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (20, N'CA05', N'Midnight Mirage Resort', 1, N'55 Mirage Boulevard, City', N'e43e9fef-32a0-4bd3-9817-3ce3b3b7cf05.jpg', N'Experience the magic of the midnight oasis.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (3, N'CA03', N'Sandy Beach Resort', 1, N'789 Ocean Avenue, City', N'5925ec07-7722-4c95-98f0-f8aa8a0a2dbc.jpg', N'A beachfront resort perfect for a relaxing getaway.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (4, N'CA04', N'Budget Inn', 1, N'10 Park Lane, City', N'c4f3bdd5-d2f1-4f2b-adfb-8620af548499.jpg', N'An affordable hotel option for budget-conscious travelers.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (5, N'CA05', N'Business Central Hotel', 1, N'55 Commerce Street, City', N'9370fb86-c4e1-486a-bfe8-8703a63bff7e.jpg', N'A convenient hotel catering to business travelers.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (6, N'CA06', N'Quaint Bed and Breakfast', 1, N'77 Maple Road, City', N'8c64a891-2cd8-416f-bc78-c0b4dcb25e51.jpg', N'A cozy and comfortable bed and breakfast.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (7, N'CA07', N'Mountain Lodge Retreat', 1, N'22 Pine Trail, City', N'83d8751d-4d6f-43d2-9598-9e9cc970a609.jpg', N'A rustic lodge nestled in the scenic mountains.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (8, N'CA08', N'Historic Heritage Hotel', 1, N'99 History Lane, City', N'0c034c84-2407-4e29-9dc1-69436257d3f8.jpg', N'A hotel with rich history and architectural charm.')
INSERT [dbo].[Hotel] ([ID], [CategoryId], [HotelName], [IsActive], [Address], [HotelImg], [Description]) VALUES (9, N'CA09', N'Family Paradise Resort', 1, N'1234 Family Avenue, City', N'be2064da-bab6-44c9-b4ca-108ba7d1d696.jpg', N'A family-friendly resort with numerous activities.')
SET IDENTITY_INSERT [dbo].[Hotel] OFF
GO
SET IDENTITY_INSERT [dbo].[Reservation] ON 

INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (1, N'US01', CAST(N'2023-01-12' AS Date), CAST(N'2023-01-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (10, N'US010', CAST(N'2023-01-14' AS Date), CAST(N'2023-01-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (100, N'US0100', CAST(N'2023-02-21' AS Date), CAST(N'2023-02-23' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (101, N'US0101', CAST(N'2023-03-12' AS Date), CAST(N'2023-03-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (102, N'US0102', CAST(N'2023-03-14' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (103, N'US0103', CAST(N'2023-03-24' AS Date), CAST(N'2023-03-27' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1530.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (104, N'US0104', CAST(N'2023-03-22' AS Date), CAST(N'2023-03-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1900.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (105, N'US0105', CAST(N'2023-03-12' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(2480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (106, N'US0106', CAST(N'2023-03-19' AS Date), CAST(N'2023-03-23' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(2640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (107, N'US0107', CAST(N'2023-03-17' AS Date), CAST(N'2023-03-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(670.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (108, N'US0108', CAST(N'2023-03-15' AS Date), CAST(N'2023-03-18' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (109, N'US0109', CAST(N'2023-03-13' AS Date), CAST(N'2023-03-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (11, N'US011', CAST(N'2023-01-16' AS Date), CAST(N'2023-01-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (110, N'US0110', CAST(N'2023-03-14' AS Date), CAST(N'2023-03-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (111, N'US0111', CAST(N'2023-03-16' AS Date), CAST(N'2023-03-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(2360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (112, N'US0112', CAST(N'2023-03-24' AS Date), CAST(N'2023-03-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (113, N'US0113', CAST(N'2023-03-23' AS Date), CAST(N'2023-03-25' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (114, N'US0114', CAST(N'2023-03-22' AS Date), CAST(N'2023-03-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (115, N'US0115', CAST(N'2023-03-16' AS Date), CAST(N'2023-03-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (116, N'US0116', CAST(N'2023-03-15' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(390.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (117, N'US0117', CAST(N'2023-03-11' AS Date), CAST(N'2023-03-12' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(650.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (118, N'US0118', CAST(N'2023-03-23' AS Date), CAST(N'2023-03-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(580.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (119, N'US0119', CAST(N'2023-03-19' AS Date), CAST(N'2023-03-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(2340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (12, N'US012', CAST(N'2023-01-24' AS Date), CAST(N'2023-01-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (120, N'US0120', CAST(N'2023-03-16' AS Date), CAST(N'2023-03-19' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1890.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (121, N'US0121', CAST(N'2023-03-18' AS Date), CAST(N'2023-03-20' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (122, N'US0122', CAST(N'2023-03-15' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(830.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (123, N'US0123', CAST(N'2023-03-23' AS Date), CAST(N'2023-03-27' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(3320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (124, N'US0124', CAST(N'2023-03-23' AS Date), CAST(N'2023-03-26' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2550.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (125, N'US0125', CAST(N'2023-03-22' AS Date), CAST(N'2023-03-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (126, N'US0126', CAST(N'2023-03-15' AS Date), CAST(N'2023-03-17' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (127, N'US0127', CAST(N'2023-03-10' AS Date), CAST(N'2023-03-11' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(590.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (128, N'US0128', CAST(N'2023-03-16' AS Date), CAST(N'2023-03-18' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (129, N'US0129', CAST(N'2023-03-17' AS Date), CAST(N'2023-03-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (13, N'US013', CAST(N'2023-01-23' AS Date), CAST(N'2023-01-25' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (130, N'US0130', CAST(N'2023-03-13' AS Date), CAST(N'2023-03-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (131, N'US0131', CAST(N'2023-03-10' AS Date), CAST(N'2023-03-13' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(2430.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (132, N'US0132', CAST(N'2023-03-12' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (133, N'US0133', CAST(N'2023-03-17' AS Date), CAST(N'2023-03-21' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (134, N'US0134', CAST(N'2023-03-14' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (135, N'US0135', CAST(N'2023-03-21' AS Date), CAST(N'2023-03-25' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (136, N'US0136', CAST(N'2023-03-12' AS Date), CAST(N'2023-03-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (137, N'US0137', CAST(N'2023-03-24' AS Date), CAST(N'2023-03-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1140.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (138, N'US0138', CAST(N'2023-03-13' AS Date), CAST(N'2023-03-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (139, N'US0139', CAST(N'2023-03-20' AS Date), CAST(N'2023-03-23' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (14, N'US014', CAST(N'2023-01-22' AS Date), CAST(N'2023-01-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (140, N'US0140', CAST(N'2023-03-21' AS Date), CAST(N'2023-03-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(570.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (141, N'US0141', CAST(N'2023-03-24' AS Date), CAST(N'2023-03-27' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(2160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (142, N'US0142', CAST(N'2023-03-13' AS Date), CAST(N'2023-03-14' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(550.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (143, N'US0143', CAST(N'2023-03-15' AS Date), CAST(N'2023-03-18' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (144, N'US0144', CAST(N'2023-03-20' AS Date), CAST(N'2023-03-23' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1740.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (145, N'US0145', CAST(N'2023-03-19' AS Date), CAST(N'2023-03-20' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (146, N'US0146', CAST(N'2023-03-19' AS Date), CAST(N'2023-03-21' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (147, N'US0147', CAST(N'2023-03-18' AS Date), CAST(N'2023-03-21' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(2070.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (148, N'US0148', CAST(N'2023-03-12' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(3320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (149, N'US0149', CAST(N'2023-03-23' AS Date), CAST(N'2023-03-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (15, N'US015', CAST(N'2023-01-16' AS Date), CAST(N'2023-01-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (150, N'US0150', CAST(N'2023-03-12' AS Date), CAST(N'2023-03-15' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2490.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (151, N'US0151', CAST(N'2023-03-21' AS Date), CAST(N'2023-03-23' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (152, N'US0152', CAST(N'2023-03-24' AS Date), CAST(N'2023-03-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(370.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (153, N'US0153', CAST(N'2023-03-13' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (154, N'US0154', CAST(N'2023-03-24' AS Date), CAST(N'2023-03-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (155, N'US0155', CAST(N'2023-03-20' AS Date), CAST(N'2023-03-24' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (156, N'US0156', CAST(N'2023-03-22' AS Date), CAST(N'2023-03-26' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(3240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (157, N'US0157', CAST(N'2023-03-10' AS Date), CAST(N'2023-03-11' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (158, N'US0158', CAST(N'2023-03-21' AS Date), CAST(N'2023-03-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(650.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (159, N'US0159', CAST(N'2023-03-18' AS Date), CAST(N'2023-03-20' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (16, N'US016', CAST(N'2023-01-15' AS Date), CAST(N'2023-01-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (160, N'US0160', CAST(N'2023-03-22' AS Date), CAST(N'2023-03-23' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (161, N'US0161', CAST(N'2023-03-24' AS Date), CAST(N'2023-03-27' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(2400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (162, N'US0162', CAST(N'2023-03-21' AS Date), CAST(N'2023-03-24' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2670.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (163, N'US0163', CAST(N'2023-03-16' AS Date), CAST(N'2023-03-17' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (164, N'US0164', CAST(N'2023-03-10' AS Date), CAST(N'2023-03-11' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (165, N'US0165', CAST(N'2023-03-21' AS Date), CAST(N'2023-03-24' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1980.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (166, N'US0166', CAST(N'2023-03-22' AS Date), CAST(N'2023-03-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (167, N'US0167', CAST(N'2023-03-13' AS Date), CAST(N'2023-03-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (168, N'US0168', CAST(N'2023-03-24' AS Date), CAST(N'2023-03-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (169, N'US0169', CAST(N'2023-03-24' AS Date), CAST(N'2023-03-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(710.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (17, N'US017', CAST(N'2023-01-11' AS Date), CAST(N'2023-01-12' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (170, N'US0170', CAST(N'2023-03-15' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(700.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (171, N'US0171', CAST(N'2023-03-13' AS Date), CAST(N'2023-03-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (172, N'US0172', CAST(N'2023-03-23' AS Date), CAST(N'2023-03-27' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (173, N'US0173', CAST(N'2023-03-20' AS Date), CAST(N'2023-03-23' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (174, N'US0174', CAST(N'2023-03-22' AS Date), CAST(N'2023-03-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (175, N'US0175', CAST(N'2023-03-19' AS Date), CAST(N'2023-03-21' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1180.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (176, N'US0176', CAST(N'2023-03-19' AS Date), CAST(N'2023-03-20' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (177, N'US0177', CAST(N'2023-03-20' AS Date), CAST(N'2023-03-22' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (178, N'US0178', CAST(N'2023-03-12' AS Date), CAST(N'2023-03-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1900.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (179, N'US0179', CAST(N'2023-03-13' AS Date), CAST(N'2023-03-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1290.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (18, N'US018', CAST(N'2023-01-23' AS Date), CAST(N'2023-01-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (180, N'US0180', CAST(N'2023-03-11' AS Date), CAST(N'2023-03-15' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (181, N'US0181', CAST(N'2023-03-17' AS Date), CAST(N'2023-03-19' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (182, N'US0182', CAST(N'2023-03-15' AS Date), CAST(N'2023-03-17' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (183, N'US0183', CAST(N'2023-03-20' AS Date), CAST(N'2023-03-23' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (184, N'US0184', CAST(N'2023-03-19' AS Date), CAST(N'2023-03-23' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (185, N'US0185', CAST(N'2023-03-11' AS Date), CAST(N'2023-03-12' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(510.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (186, N'US0186', CAST(N'2023-03-20' AS Date), CAST(N'2023-03-22' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (187, N'US0187', CAST(N'2023-03-18' AS Date), CAST(N'2023-03-19' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (188, N'US0188', CAST(N'2023-03-16' AS Date), CAST(N'2023-03-18' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (189, N'US0189', CAST(N'2023-03-17' AS Date), CAST(N'2023-03-20' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (19, N'US019', CAST(N'2023-01-19' AS Date), CAST(N'2023-01-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(2850.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (190, N'US0190', CAST(N'2023-04-12' AS Date), CAST(N'2023-04-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (191, N'US0191', CAST(N'2023-04-24' AS Date), CAST(N'2023-04-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (192, N'US0192', CAST(N'2023-04-13' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1740.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (193, N'US0193', CAST(N'2023-04-15' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(620.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (194, N'US0194', CAST(N'2023-04-22' AS Date), CAST(N'2023-04-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1060.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (195, N'US0195', CAST(N'2023-04-20' AS Date), CAST(N'2023-04-24' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (196, N'US0196', CAST(N'2023-04-16' AS Date), CAST(N'2023-04-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (197, N'US0197', CAST(N'2023-04-12' AS Date), CAST(N'2023-04-13' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(250.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (198, N'US0198', CAST(N'2023-04-17' AS Date), CAST(N'2023-04-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (199, N'US0199', CAST(N'2023-04-18' AS Date), CAST(N'2023-04-19' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(300.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (2, N'US02', CAST(N'2023-01-14' AS Date), CAST(N'2023-01-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (20, N'US020', CAST(N'2023-01-16' AS Date), CAST(N'2023-01-19' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(390.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (200, N'US0200', CAST(N'2023-04-16' AS Date), CAST(N'2023-04-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (201, N'US0201', CAST(N'2023-04-19' AS Date), CAST(N'2023-04-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (202, N'US0202', CAST(N'2023-04-14' AS Date), CAST(N'2023-04-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (203, N'US0203', CAST(N'2023-04-18' AS Date), CAST(N'2023-04-21' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1740.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (204, N'US0204', CAST(N'2023-04-13' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (205, N'US0205', CAST(N'2023-04-16' AS Date), CAST(N'2023-04-17' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (206, N'US0206', CAST(N'2023-04-23' AS Date), CAST(N'2023-04-25' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (207, N'US0207', CAST(N'2023-04-17' AS Date), CAST(N'2023-04-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(590.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (208, N'US0208', CAST(N'2023-04-14' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1700.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (209, N'US0209', CAST(N'2023-04-14' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (21, N'US021', CAST(N'2023-01-18' AS Date), CAST(N'2023-01-20' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (210, N'US0210', CAST(N'2023-04-15' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (211, N'US0211', CAST(N'2023-04-13' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (212, N'US0212', CAST(N'2023-04-12' AS Date), CAST(N'2023-04-13' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(390.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (213, N'US0213', CAST(N'2023-04-21' AS Date), CAST(N'2023-04-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(270.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (214, N'US0214', CAST(N'2023-04-19' AS Date), CAST(N'2023-04-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (215, N'US0215', CAST(N'2023-04-16' AS Date), CAST(N'2023-04-19' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1980.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (216, N'US0216', CAST(N'2023-04-18' AS Date), CAST(N'2023-04-20' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (217, N'US0217', CAST(N'2023-04-19' AS Date), CAST(N'2023-04-23' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (218, N'US0218', CAST(N'2023-04-15' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (219, N'US0219', CAST(N'2023-04-21' AS Date), CAST(N'2023-04-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(530.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (22, N'US022', CAST(N'2023-01-15' AS Date), CAST(N'2023-01-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(450.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (220, N'US0220', CAST(N'2023-04-19' AS Date), CAST(N'2023-04-20' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (221, N'US0221', CAST(N'2023-04-12' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (222, N'US0222', CAST(N'2023-04-22' AS Date), CAST(N'2023-04-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1710.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (223, N'US0223', CAST(N'2023-04-13' AS Date), CAST(N'2023-04-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (224, N'US0224', CAST(N'2023-04-13' AS Date), CAST(N'2023-04-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (225, N'US0225', CAST(N'2023-04-22' AS Date), CAST(N'2023-04-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (226, N'US0226', CAST(N'2023-04-16' AS Date), CAST(N'2023-04-18' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (227, N'US0227', CAST(N'2023-04-24' AS Date), CAST(N'2023-04-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (228, N'US0228', CAST(N'2023-04-19' AS Date), CAST(N'2023-04-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (229, N'US0229', CAST(N'2023-04-22' AS Date), CAST(N'2023-04-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (23, N'US023', CAST(N'2023-01-23' AS Date), CAST(N'2023-01-27' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(2640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (230, N'US0230', CAST(N'2023-04-10' AS Date), CAST(N'2023-04-13' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1710.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (231, N'US0231', CAST(N'2023-04-15' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(300.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (232, N'US0232', CAST(N'2023-04-14' AS Date), CAST(N'2023-04-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (233, N'US0233', CAST(N'2023-04-15' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (234, N'US0234', CAST(N'2023-04-14' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (235, N'US0235', CAST(N'2023-04-22' AS Date), CAST(N'2023-04-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1950.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (236, N'US0236', CAST(N'2023-04-22' AS Date), CAST(N'2023-04-26' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (237, N'US0237', CAST(N'2023-04-13' AS Date), CAST(N'2023-04-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (238, N'US0238', CAST(N'2023-04-24' AS Date), CAST(N'2023-04-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1700.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (239, N'US0239', CAST(N'2023-04-21' AS Date), CAST(N'2023-04-24' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (24, N'US024', CAST(N'2023-01-23' AS Date), CAST(N'2023-01-26' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (240, N'US0240', CAST(N'2023-04-11' AS Date), CAST(N'2023-04-14' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (241, N'US0241', CAST(N'2023-04-13' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1980.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (242, N'US0242', CAST(N'2023-04-21' AS Date), CAST(N'2023-04-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(610.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (243, N'US0243', CAST(N'2023-04-20' AS Date), CAST(N'2023-04-24' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (244, N'US0244', CAST(N'2023-04-12' AS Date), CAST(N'2023-04-13' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (245, N'US0245', CAST(N'2023-04-20' AS Date), CAST(N'2023-04-24' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (246, N'US0246', CAST(N'2023-04-15' AS Date), CAST(N'2023-04-18' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(810.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (247, N'US0247', CAST(N'2023-04-24' AS Date), CAST(N'2023-04-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (248, N'US0248', CAST(N'2023-04-16' AS Date), CAST(N'2023-04-17' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (249, N'US0249', CAST(N'2023-04-13' AS Date), CAST(N'2023-04-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (25, N'US025', CAST(N'2023-01-22' AS Date), CAST(N'2023-01-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(2130.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (250, N'US0250', CAST(N'2023-04-19' AS Date), CAST(N'2023-04-21' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1040.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (251, N'US0251', CAST(N'2023-04-13' AS Date), CAST(N'2023-04-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (252, N'US0252', CAST(N'2023-04-18' AS Date), CAST(N'2023-04-19' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(430.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (253, N'US0253', CAST(N'2023-04-18' AS Date), CAST(N'2023-04-22' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (254, N'US0254', CAST(N'2023-04-23' AS Date), CAST(N'2023-04-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(710.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (255, N'US0255', CAST(N'2023-04-10' AS Date), CAST(N'2023-04-12' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (256, N'US0256', CAST(N'2023-04-14' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (257, N'US0257', CAST(N'2023-04-15' AS Date), CAST(N'2023-04-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (258, N'US0258', CAST(N'2023-04-24' AS Date), CAST(N'2023-04-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (259, N'US0259', CAST(N'2023-04-23' AS Date), CAST(N'2023-04-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (26, N'US026', CAST(N'2023-01-15' AS Date), CAST(N'2023-01-17' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (260, N'US0260', CAST(N'2023-05-12' AS Date), CAST(N'2023-05-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (261, N'US0261', CAST(N'2023-05-24' AS Date), CAST(N'2023-05-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(810.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (262, N'US0262', CAST(N'2023-05-13' AS Date), CAST(N'2023-05-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1590.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (263, N'US0263', CAST(N'2023-05-15' AS Date), CAST(N'2023-05-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (264, N'US0264', CAST(N'2023-05-22' AS Date), CAST(N'2023-05-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1180.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (265, N'US0265', CAST(N'2023-05-20' AS Date), CAST(N'2023-05-24' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (266, N'US0266', CAST(N'2023-05-16' AS Date), CAST(N'2023-05-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (267, N'US0267', CAST(N'2023-05-12' AS Date), CAST(N'2023-05-13' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(650.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (268, N'US0268', CAST(N'2023-05-17' AS Date), CAST(N'2023-05-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (269, N'US0269', CAST(N'2023-05-18' AS Date), CAST(N'2023-05-19' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(830.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (27, N'US027', CAST(N'2023-01-10' AS Date), CAST(N'2023-01-11' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (270, N'US0270', CAST(N'2023-05-16' AS Date), CAST(N'2023-05-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (271, N'US0271', CAST(N'2023-05-19' AS Date), CAST(N'2023-05-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2190.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (272, N'US0272', CAST(N'2023-05-14' AS Date), CAST(N'2023-05-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (273, N'US0273', CAST(N'2023-05-18' AS Date), CAST(N'2023-05-21' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(810.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (274, N'US0274', CAST(N'2023-05-13' AS Date), CAST(N'2023-05-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1710.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (275, N'US0275', CAST(N'2023-05-16' AS Date), CAST(N'2023-05-17' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (276, N'US0276', CAST(N'2023-05-23' AS Date), CAST(N'2023-05-25' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(820.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (277, N'US0277', CAST(N'2023-05-17' AS Date), CAST(N'2023-05-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (278, N'US0278', CAST(N'2023-05-14' AS Date), CAST(N'2023-05-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (279, N'US0279', CAST(N'2023-05-14' AS Date), CAST(N'2023-05-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (28, N'US028', CAST(N'2023-01-16' AS Date), CAST(N'2023-01-18' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (280, N'US0280', CAST(N'2023-05-15' AS Date), CAST(N'2023-05-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (281, N'US0281', CAST(N'2023-05-13' AS Date), CAST(N'2023-05-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1530.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (282, N'US0282', CAST(N'2023-05-12' AS Date), CAST(N'2023-05-13' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (283, N'US0283', CAST(N'2023-05-21' AS Date), CAST(N'2023-05-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(570.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (284, N'US0284', CAST(N'2023-05-19' AS Date), CAST(N'2023-05-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (285, N'US0285', CAST(N'2023-05-16' AS Date), CAST(N'2023-05-19' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2430.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (286, N'US0286', CAST(N'2023-05-18' AS Date), CAST(N'2023-05-20' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1300.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (287, N'US0287', CAST(N'2023-05-19' AS Date), CAST(N'2023-05-23' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (288, N'US0288', CAST(N'2023-05-15' AS Date), CAST(N'2023-05-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (289, N'US0289', CAST(N'2023-05-21' AS Date), CAST(N'2023-05-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (29, N'US029', CAST(N'2023-01-17' AS Date), CAST(N'2023-01-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (290, N'US0290', CAST(N'2023-05-19' AS Date), CAST(N'2023-05-20' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(610.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (291, N'US0291', CAST(N'2023-05-12' AS Date), CAST(N'2023-05-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (292, N'US0292', CAST(N'2023-05-22' AS Date), CAST(N'2023-05-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (293, N'US0293', CAST(N'2023-05-13' AS Date), CAST(N'2023-05-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (294, N'US0294', CAST(N'2023-05-13' AS Date), CAST(N'2023-05-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (295, N'US0295', CAST(N'2023-05-22' AS Date), CAST(N'2023-05-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (296, N'US0296', CAST(N'2023-05-16' AS Date), CAST(N'2023-05-18' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(900.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (297, N'US0297', CAST(N'2023-05-24' AS Date), CAST(N'2023-05-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (298, N'US0298', CAST(N'2023-05-19' AS Date), CAST(N'2023-05-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1050.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (299, N'US0299', CAST(N'2023-05-22' AS Date), CAST(N'2023-05-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (3, N'US03', CAST(N'2023-01-24' AS Date), CAST(N'2023-01-27' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (30, N'US030', CAST(N'2023-01-13' AS Date), CAST(N'2023-01-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (300, N'US0300', CAST(N'2023-05-10' AS Date), CAST(N'2023-05-13' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (301, N'US0301', CAST(N'2023-06-12' AS Date), CAST(N'2023-06-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (302, N'US0302', CAST(N'2023-06-24' AS Date), CAST(N'2023-06-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(430.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (303, N'US0303', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (304, N'US0304', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(270.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (305, N'US0305', CAST(N'2023-06-22' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (306, N'US0306', CAST(N'2023-06-20' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (307, N'US0307', CAST(N'2023-06-16' AS Date), CAST(N'2023-06-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (308, N'US0308', CAST(N'2023-06-12' AS Date), CAST(N'2023-06-13' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (309, N'US0309', CAST(N'2023-06-17' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(670.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (31, N'US031', CAST(N'2023-01-10' AS Date), CAST(N'2023-01-13' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (310, N'US0310', CAST(N'2023-06-18' AS Date), CAST(N'2023-06-19' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (311, N'US0311', CAST(N'2023-06-16' AS Date), CAST(N'2023-06-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (312, N'US0312', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(810.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (313, N'US0313', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (314, N'US0314', CAST(N'2023-06-18' AS Date), CAST(N'2023-06-21' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1770.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (315, N'US0315', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (316, N'US0316', CAST(N'2023-06-16' AS Date), CAST(N'2023-06-17' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (317, N'US0317', CAST(N'2023-06-23' AS Date), CAST(N'2023-06-25' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (318, N'US0318', CAST(N'2023-06-17' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(710.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (319, N'US0319', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1140.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (32, N'US032', CAST(N'2023-01-12' AS Date), CAST(N'2023-01-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (320, N'US0320', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (321, N'US0321', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(390.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (322, N'US0322', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1350.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (323, N'US0323', CAST(N'2023-06-12' AS Date), CAST(N'2023-06-13' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(130.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (324, N'US0324', CAST(N'2023-06-21' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(700.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (325, N'US0325', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (326, N'US0326', CAST(N'2023-06-16' AS Date), CAST(N'2023-06-19' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1890.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (327, N'US0327', CAST(N'2023-06-18' AS Date), CAST(N'2023-06-20' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (328, N'US0328', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-23' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (329, N'US0329', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(590.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (33, N'US033', CAST(N'2023-01-17' AS Date), CAST(N'2023-01-21' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (330, N'US0330', CAST(N'2023-06-21' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(830.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (331, N'US0331', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-20' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (332, N'US0332', CAST(N'2023-06-12' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (333, N'US0333', CAST(N'2023-06-22' AS Date), CAST(N'2023-06-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (334, N'US0334', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (335, N'US0335', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (336, N'US0336', CAST(N'2023-06-22' AS Date), CAST(N'2023-06-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (337, N'US0337', CAST(N'2023-06-16' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (338, N'US0338', CAST(N'2023-06-24' AS Date), CAST(N'2023-06-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (339, N'US0339', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(300.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (34, N'US034', CAST(N'2023-01-14' AS Date), CAST(N'2023-01-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(980.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (340, N'US0340', CAST(N'2023-06-22' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (341, N'US0341', CAST(N'2023-06-10' AS Date), CAST(N'2023-06-13' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (342, N'US0342', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(570.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (343, N'US0343', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (344, N'US0344', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (345, N'US0345', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (346, N'US0346', CAST(N'2023-06-22' AS Date), CAST(N'2023-06-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(330.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (347, N'US0347', CAST(N'2023-06-22' AS Date), CAST(N'2023-06-26' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (348, N'US0348', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (349, N'US0349', CAST(N'2023-06-24' AS Date), CAST(N'2023-06-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1060.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (35, N'US035', CAST(N'2023-01-21' AS Date), CAST(N'2023-01-25' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (350, N'US0350', CAST(N'2023-06-21' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (351, N'US0351', CAST(N'2023-06-11' AS Date), CAST(N'2023-06-14' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (352, N'US0352', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(330.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (353, N'US0353', CAST(N'2023-06-21' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (354, N'US0354', CAST(N'2023-06-20' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (355, N'US0355', CAST(N'2023-06-12' AS Date), CAST(N'2023-06-13' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (356, N'US0356', CAST(N'2023-06-20' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (357, N'US0357', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1950.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (358, N'US0358', CAST(N'2023-06-24' AS Date), CAST(N'2023-06-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(580.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (359, N'US0359', CAST(N'2023-06-16' AS Date), CAST(N'2023-06-17' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(700.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (36, N'US036', CAST(N'2023-01-12' AS Date), CAST(N'2023-01-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (360, N'US0360', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (361, N'US0361', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-21' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(820.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (362, N'US0362', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (363, N'US0363', CAST(N'2023-06-18' AS Date), CAST(N'2023-06-19' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(830.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (364, N'US0364', CAST(N'2023-06-18' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (365, N'US0365', CAST(N'2023-06-23' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (366, N'US0366', CAST(N'2023-06-10' AS Date), CAST(N'2023-06-12' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1020.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (367, N'US0367', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (368, N'US0368', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(270.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (369, N'US0369', CAST(N'2023-06-24' AS Date), CAST(N'2023-06-25' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (37, N'US037', CAST(N'2023-01-24' AS Date), CAST(N'2023-01-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (370, N'US0370', CAST(N'2023-06-23' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (371, N'US0371', CAST(N'2023-06-23' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (372, N'US0372', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (373, N'US0373', CAST(N'2023-06-20' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (374, N'US0374', CAST(N'2023-06-23' AS Date), CAST(N'2023-06-27' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (375, N'US0375', CAST(N'2023-06-18' AS Date), CAST(N'2023-06-21' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1950.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (376, N'US0376', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-14' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (377, N'US0377', CAST(N'2023-06-21' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (378, N'US0378', CAST(N'2023-06-24' AS Date), CAST(N'2023-06-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (379, N'US0379', CAST(N'2023-06-17' AS Date), CAST(N'2023-06-19' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (38, N'US038', CAST(N'2023-01-13' AS Date), CAST(N'2023-01-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1700.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (380, N'US0380', CAST(N'2023-06-23' AS Date), CAST(N'2023-06-26' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2550.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (381, N'US0381', CAST(N'2023-06-24' AS Date), CAST(N'2023-06-27' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (382, N'US0382', CAST(N'2023-06-18' AS Date), CAST(N'2023-06-20' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (383, N'US0383', CAST(N'2023-06-23' AS Date), CAST(N'2023-06-27' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (384, N'US0384', CAST(N'2023-06-12' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (385, N'US0385', CAST(N'2023-06-10' AS Date), CAST(N'2023-06-11' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (386, N'US0386', CAST(N'2023-06-17' AS Date), CAST(N'2023-06-20' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (387, N'US0387', CAST(N'2023-06-18' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (388, N'US0388', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(630.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (389, N'US0389', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(820.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (39, N'US039', CAST(N'2023-01-20' AS Date), CAST(N'2023-01-23' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (390, N'US0390', CAST(N'2023-06-11' AS Date), CAST(N'2023-06-15' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (391, N'US0391', CAST(N'2023-06-16' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (392, N'US0392', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-17' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (393, N'US0393', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(270.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (394, N'US0394', CAST(N'2023-06-21' AS Date), CAST(N'2023-06-23' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (395, N'US0395', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-21' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (396, N'US0396', CAST(N'2023-06-17' AS Date), CAST(N'2023-06-21' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (397, N'US0397', CAST(N'2023-06-20' AS Date), CAST(N'2023-06-23' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (398, N'US0398', CAST(N'2023-06-22' AS Date), CAST(N'2023-06-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (399, N'US0399', CAST(N'2023-06-12' AS Date), CAST(N'2023-06-13' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(350.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (4, N'US04', CAST(N'2023-01-22' AS Date), CAST(N'2023-01-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1060.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (40, N'US040', CAST(N'2023-01-21' AS Date), CAST(N'2023-01-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (400, N'US0400', CAST(N'2023-06-21' AS Date), CAST(N'2023-06-24' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(510.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (401, N'US0401', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-20' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(450.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (402, N'US0402', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (403, N'US0403', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-17' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (404, N'US0404', CAST(N'2023-06-20' AS Date), CAST(N'2023-06-21' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (405, N'US0405', CAST(N'2023-06-13' AS Date), CAST(N'2023-06-16' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (406, N'US0406', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1040.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (407, N'US0407', CAST(N'2023-06-14' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (408, N'US0408', CAST(N'2023-06-16' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (409, N'US0409', CAST(N'2023-06-15' AS Date), CAST(N'2023-06-17' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (41, N'US041', CAST(N'2023-01-24' AS Date), CAST(N'2023-01-27' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(390.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (410, N'US0410', CAST(N'2023-06-21' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(210.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (411, N'US0411', CAST(N'2023-06-17' AS Date), CAST(N'2023-06-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (412, N'US0412', CAST(N'2023-06-19' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(810.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (413, N'US0413', CAST(N'2023-06-11' AS Date), CAST(N'2023-06-12' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (414, N'US0414', CAST(N'2023-06-18' AS Date), CAST(N'2023-06-22' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (415, N'US0415', CAST(N'2023-06-23' AS Date), CAST(N'2023-06-25' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (416, N'US01', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-14' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (417, N'US02', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (418, N'US03', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (419, N'US04', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (42, N'US042', CAST(N'2023-01-13' AS Date), CAST(N'2023-01-14' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (420, N'US05', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (421, N'US06', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (422, N'US07', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (423, N'US08', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (424, N'US09', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (425, N'US010', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (426, N'US011', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (427, N'US012', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (428, N'US013', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (429, N'US014', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (43, N'US043', CAST(N'2023-01-15' AS Date), CAST(N'2023-01-18' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1650.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (430, N'US015', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(930.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (431, N'US016', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (432, N'US017', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (433, N'US018', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (434, N'US019', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (435, N'US020', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (436, N'US021', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(140.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (437, N'US022', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(810.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (438, N'US023', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(150.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (439, N'US024', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (44, N'US044', CAST(N'2023-01-20' AS Date), CAST(N'2023-01-23' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (440, N'US025', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(810.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (441, N'US026', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (442, N'US027', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (443, N'US028', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-23' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (444, N'US029', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (445, N'US030', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(420.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (446, N'US031', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (447, N'US032', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (448, N'US033', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (449, N'US034', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (45, N'US045', CAST(N'2023-01-19' AS Date), CAST(N'2023-01-20' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (450, N'US035', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (451, N'US036', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (452, N'US037', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (453, N'US038', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-26' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (454, N'US039', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1350.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (455, N'US040', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (456, N'US041', CAST(N'2022-07-10' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1350.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (457, N'US042', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(390.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (458, N'US043', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1240.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (459, N'US044', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (46, N'US046', CAST(N'2023-01-19' AS Date), CAST(N'2023-01-21' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (460, N'US045', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(820.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (461, N'US046', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (462, N'US047', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-26' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (463, N'US048', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (464, N'US049', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-26' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (465, N'US050', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (466, N'US051', CAST(N'2022-07-11' AS Date), CAST(N'2022-07-14' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (467, N'US052', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (468, N'US053', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (469, N'US054', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (47, N'US047', CAST(N'2023-01-18' AS Date), CAST(N'2023-01-21' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(510.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (470, N'US055', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(290.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (471, N'US056', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (472, N'US057', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (473, N'US058', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (474, N'US059', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(250.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (475, N'US060', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (476, N'US061', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (477, N'US062', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (478, N'US063', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (479, N'US064', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (48, N'US048', CAST(N'2023-01-12' AS Date), CAST(N'2023-01-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (480, N'US065', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (481, N'US066', CAST(N'2022-07-10' AS Date), CAST(N'2022-07-12' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (482, N'US067', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (483, N'US068', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (484, N'US069', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (485, N'US070', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (486, N'US071', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (487, N'US072', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (488, N'US073', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (489, N'US074', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-27' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (49, N'US049', CAST(N'2023-01-23' AS Date), CAST(N'2023-01-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (490, N'US075', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(930.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (491, N'US076', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-14' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (492, N'US077', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (493, N'US078', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-26' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (494, N'US079', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (495, N'US080', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-26' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(330.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (496, N'US081', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1020.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (497, N'US082', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (498, N'US083', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-27' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (499, N'US084', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (5, N'US05', CAST(N'2023-01-12' AS Date), CAST(N'2023-01-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (50, N'US050', CAST(N'2023-02-12' AS Date), CAST(N'2023-02-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (500, N'US085', CAST(N'2022-07-10' AS Date), CAST(N'2022-07-11' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(310.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (501, N'US086', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (502, N'US087', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (503, N'US088', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (504, N'US089', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (505, N'US090', CAST(N'2022-07-11' AS Date), CAST(N'2022-07-15' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (506, N'US091', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (507, N'US092', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (508, N'US093', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (509, N'US094', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-23' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (51, N'US051', CAST(N'2023-02-14' AS Date), CAST(N'2023-02-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (510, N'US095', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (511, N'US096', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (512, N'US097', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-23' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (513, N'US098', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (514, N'US099', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(450.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (515, N'US0100', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(390.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (516, N'US0101', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(450.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (517, N'US0102', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(390.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (518, N'US0103', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(930.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (519, N'US0104', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (52, N'US052', CAST(N'2023-02-24' AS Date), CAST(N'2023-02-27' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (520, N'US0105', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1230.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (521, N'US0106', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (522, N'US0107', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (523, N'US0108', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(940.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (524, N'US0109', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (525, N'US0110', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (526, N'US0111', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (527, N'US0112', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1350.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (528, N'US0113', CAST(N'2022-07-11' AS Date), CAST(N'2022-07-12' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (529, N'US0114', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (53, N'US053', CAST(N'2023-02-22' AS Date), CAST(N'2023-02-24' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1060.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (530, N'US0115', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(940.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (531, N'US0116', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (532, N'US0117', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (533, N'US0118', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(510.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (534, N'US0119', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (535, N'US0120', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1050.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (536, N'US0121', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (537, N'US0122', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(900.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (538, N'US0123', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(130.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (539, N'US0124', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(370.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (54, N'US054', CAST(N'2023-02-12' AS Date), CAST(N'2023-02-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (540, N'US0125', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (541, N'US0126', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (542, N'US0127', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(330.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (543, N'US0128', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (544, N'US0129', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-23' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(630.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (545, N'US0130', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(870.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (546, N'US0131', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (547, N'US0132', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-27' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (548, N'US0133', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (549, N'US0134', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (55, N'US055', CAST(N'2023-02-19' AS Date), CAST(N'2023-02-23' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (550, N'US0135', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-27' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (551, N'US0136', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (552, N'US0137', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (553, N'US0138', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (554, N'US0139', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (555, N'US0140', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (556, N'US0141', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-26' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (557, N'US0142', CAST(N'2022-07-10' AS Date), CAST(N'2022-07-12' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (558, N'US0143', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (559, N'US0144', CAST(N'2022-07-24' AS Date), CAST(N'2022-07-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (56, N'US056', CAST(N'2023-02-17' AS Date), CAST(N'2023-02-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (560, N'US0145', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (561, N'US0146', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (562, N'US0147', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1040.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (563, N'US0148', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (564, N'US0149', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (565, N'US0150', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-23' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (566, N'US0151', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (567, N'US0152', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (568, N'US0153', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (569, N'US0154', CAST(N'2022-07-11' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(820.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (57, N'US057', CAST(N'2023-02-15' AS Date), CAST(N'2023-02-18' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1620.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (570, N'US0155', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (571, N'US0156', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (572, N'US0157', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(330.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (573, N'US0158', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(740.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (574, N'US0159', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (575, N'US0160', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (576, N'US0161', CAST(N'2022-07-11' AS Date), CAST(N'2022-07-14' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (577, N'US0162', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-26' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (578, N'US0163', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (579, N'US0164', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(490.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (58, N'US058', CAST(N'2023-02-13' AS Date), CAST(N'2023-02-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (580, N'US0165', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (581, N'US0166', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(140.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (582, N'US0167', CAST(N'2022-07-15' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (583, N'US0168', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (584, N'US0169', CAST(N'2022-07-11' AS Date), CAST(N'2022-07-14' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1110.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (585, N'US0170', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (586, N'US0171', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (587, N'US0172', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(350.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (588, N'US0173', CAST(N'2022-07-11' AS Date), CAST(N'2022-07-12' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (589, N'US0174', CAST(N'2022-07-10' AS Date), CAST(N'2022-07-12' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (59, N'US059', CAST(N'2023-02-14' AS Date), CAST(N'2023-02-18' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (590, N'US0175', CAST(N'2022-07-23' AS Date), CAST(N'2022-07-26' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1350.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (591, N'US0176', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (592, N'US0177', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(570.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (593, N'US0178', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (594, N'US0179', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(420.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (595, N'US0180', CAST(N'2022-07-11' AS Date), CAST(N'2022-07-15' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (596, N'US0181', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-14' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(210.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (597, N'US0182', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(190.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (598, N'US0183', CAST(N'2022-07-19' AS Date), CAST(N'2022-07-23' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (599, N'US0184', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-23' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (6, N'US06', CAST(N'2023-01-19' AS Date), CAST(N'2023-01-23' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (60, N'US060', CAST(N'2023-02-16' AS Date), CAST(N'2023-02-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(2320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (600, N'US0185', CAST(N'2022-07-20' AS Date), CAST(N'2022-07-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (601, N'US0186', CAST(N'2022-07-16' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (602, N'US0187', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-20' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (603, N'US0188', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (604, N'US0189', CAST(N'2022-07-12' AS Date), CAST(N'2022-07-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(180.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (605, N'US0190', CAST(N'2022-07-22' AS Date), CAST(N'2022-07-23' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(210.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (606, N'US0191', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-23' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (607, N'US0192', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (608, N'US0193', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-21' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (609, N'US0194', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-22' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (61, N'US061', CAST(N'2023-02-24' AS Date), CAST(N'2023-02-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (610, N'US0195', CAST(N'2022-07-14' AS Date), CAST(N'2022-07-15' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (611, N'US0196', CAST(N'2022-07-17' AS Date), CAST(N'2022-07-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (612, N'US0197', CAST(N'2022-07-18' AS Date), CAST(N'2022-07-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(180.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (613, N'US0198', CAST(N'2022-07-21' AS Date), CAST(N'2022-07-25' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (614, N'US0199', CAST(N'2022-07-13' AS Date), CAST(N'2022-07-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (615, N'US0416', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-14' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (616, N'US0417', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (617, N'US0418', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (618, N'US0419', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(270.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (619, N'US0420', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (62, N'US062', CAST(N'2023-02-23' AS Date), CAST(N'2023-02-25' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (620, N'US0421', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (621, N'US0422', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (622, N'US0423', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (623, N'US0424', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (624, N'US0425', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (625, N'US0426', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (626, N'US0427', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(390.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (627, N'US0428', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (628, N'US0429', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(930.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (629, N'US0430', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (63, N'US063', CAST(N'2023-02-22' AS Date), CAST(N'2023-02-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1770.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (630, N'US0431', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (631, N'US0432', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (632, N'US0433', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(110.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (633, N'US0434', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (634, N'US0435', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (635, N'US0436', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(150.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (636, N'US0437', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(300.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (637, N'US0438', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (638, N'US0439', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(270.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (639, N'US0440', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (64, N'US064', CAST(N'2023-02-16' AS Date), CAST(N'2023-02-20' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (640, N'US0441', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (641, N'US0442', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (642, N'US0443', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-23' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (643, N'US0444', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (644, N'US0445', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(250.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (645, N'US0446', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (646, N'US0447', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (647, N'US0448', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(510.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (648, N'US0449', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (649, N'US0450', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (65, N'US065', CAST(N'2023-02-15' AS Date), CAST(N'2023-02-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(730.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (650, N'US0451', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (651, N'US0452', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (652, N'US0453', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-26' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(900.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (653, N'US0454', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (654, N'US0455', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(620.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (655, N'US0456', CAST(N'2022-08-10' AS Date), CAST(N'2022-08-13' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (656, N'US0457', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (657, N'US0458', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (658, N'US0459', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(230.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (659, N'US0460', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(940.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (66, N'US066', CAST(N'2023-02-11' AS Date), CAST(N'2023-02-12' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (660, N'US0461', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (661, N'US0462', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-26' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (662, N'US0463', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (663, N'US0464', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-26' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (664, N'US0465', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (665, N'US0466', CAST(N'2022-08-11' AS Date), CAST(N'2022-08-14' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (666, N'US0467', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(870.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (667, N'US0468', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(260.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (668, N'US0469', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (669, N'US0470', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(250.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (67, N'US067', CAST(N'2023-02-23' AS Date), CAST(N'2023-02-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (670, N'US0471', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (671, N'US0472', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(810.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (672, N'US0473', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (673, N'US0474', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (674, N'US0475', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (675, N'US0476', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (676, N'US0477', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (677, N'US0478', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (678, N'US0479', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (679, N'US0480', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (68, N'US068', CAST(N'2023-02-19' AS Date), CAST(N'2023-02-22' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(2850.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (680, N'US0481', CAST(N'2022-08-10' AS Date), CAST(N'2022-08-12' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (681, N'US0482', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (682, N'US0483', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(130.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (683, N'US0484', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (684, N'US0485', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(310.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (685, N'US0486', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (686, N'US0487', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (687, N'US0488', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (688, N'US0489', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-27' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (689, N'US0490', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1020.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (69, N'US069', CAST(N'2023-02-16' AS Date), CAST(N'2023-02-19' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1710.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (690, N'US0491', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-14' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (691, N'US0492', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(130.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (692, N'US0493', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-26' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (693, N'US0494', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (694, N'US0495', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-26' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(930.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (695, N'US0496', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (696, N'US0497', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (697, N'US0498', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-27' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (698, N'US0499', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (699, N'US0500', CAST(N'2022-08-10' AS Date), CAST(N'2022-08-11' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (7, N'US07', CAST(N'2023-01-17' AS Date), CAST(N'2023-01-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(420.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (70, N'US070', CAST(N'2023-02-18' AS Date), CAST(N'2023-02-20' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (700, N'US0501', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(750.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (701, N'US0502', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (702, N'US0503', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1140.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (703, N'US0504', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (704, N'US0505', CAST(N'2022-08-11' AS Date), CAST(N'2022-08-15' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (705, N'US0506', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (706, N'US0507', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(900.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (707, N'US0508', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(130.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (708, N'US0509', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-23' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(900.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (709, N'US0510', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (71, N'US071', CAST(N'2023-02-15' AS Date), CAST(N'2023-02-16' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(450.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (710, N'US0511', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (711, N'US0512', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-23' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (712, N'US0513', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1230.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (713, N'US0514', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (714, N'US0515', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (715, N'US0516', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (716, N'US0517', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (717, N'US0518', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1230.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (718, N'US0519', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(450.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (719, N'US0520', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (72, N'US072', CAST(N'2023-02-23' AS Date), CAST(N'2023-02-27' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(2640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (720, N'US0521', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (721, N'US0522', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (722, N'US0523', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(940.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (723, N'US0524', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (724, N'US0525', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (725, N'US0526', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(130.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (726, N'US0527', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1050.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (727, N'US0528', CAST(N'2022-08-11' AS Date), CAST(N'2022-08-12' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (728, N'US0529', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (729, N'US0530', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(740.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (73, N'US073', CAST(N'2023-02-23' AS Date), CAST(N'2023-02-26' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (730, N'US0531', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(110.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (731, N'US0532', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (732, N'US0533', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (733, N'US0534', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (734, N'US0535', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(630.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (735, N'US0536', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (736, N'US0537', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (737, N'US0538', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (738, N'US0539', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (739, N'US0540', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (74, N'US074', CAST(N'2023-02-22' AS Date), CAST(N'2023-02-25' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(2130.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (740, N'US0541', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (741, N'US0542', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (742, N'US0543', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (743, N'US0544', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-23' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (744, N'US0545', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (745, N'US0546', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (746, N'US0547', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-27' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (747, N'US0548', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (748, N'US0549', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (749, N'US0550', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-27' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (75, N'US075', CAST(N'2023-02-15' AS Date), CAST(N'2023-02-17' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (750, N'US0551', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (751, N'US0552', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (752, N'US0553', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (753, N'US0554', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (754, N'US0555', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (755, N'US0556', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-26' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (756, N'US0557', CAST(N'2022-08-10' AS Date), CAST(N'2022-08-12' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(420.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (757, N'US0558', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (758, N'US0559', CAST(N'2022-08-24' AS Date), CAST(N'2022-08-27' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(750.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (759, N'US0560', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (76, N'US076', CAST(N'2023-02-10' AS Date), CAST(N'2023-02-11' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(650.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (760, N'US0561', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (761, N'US0562', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (762, N'US0563', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (763, N'US0564', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (764, N'US0565', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-23' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (765, N'US0566', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (766, N'US0567', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1020.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (767, N'US0568', CAST(N'2022-08-21' AS Date), CAST(N'2022-08-25' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (768, N'US0569', CAST(N'2022-08-11' AS Date), CAST(N'2022-08-13' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (769, N'US0570', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(420.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (77, N'US077', CAST(N'2023-02-16' AS Date), CAST(N'2023-02-18' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (770, N'US0571', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(140.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (771, N'US0572', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (772, N'US0573', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(740.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (773, N'US0574', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(170.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (774, N'US0575', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1050.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (775, N'US0576', CAST(N'2022-08-11' AS Date), CAST(N'2022-08-14' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(510.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (776, N'US0577', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-26' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (777, N'US0578', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(980.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (778, N'US0579', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-24' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (779, N'US0580', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(570.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (78, N'US078', CAST(N'2023-02-17' AS Date), CAST(N'2023-02-18' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (780, N'US0581', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (781, N'US0582', CAST(N'2022-08-15' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (782, N'US0583', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(190.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (783, N'US0584', CAST(N'2022-08-11' AS Date), CAST(N'2022-08-14' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(630.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (784, N'US0585', CAST(N'2022-08-16' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (785, N'US0586', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-22' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (786, N'US0587', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(450.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (787, N'US0588', CAST(N'2022-08-11' AS Date), CAST(N'2022-08-12' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(450.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (788, N'US0589', CAST(N'2022-08-10' AS Date), CAST(N'2022-08-12' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (789, N'US0590', CAST(N'2022-08-23' AS Date), CAST(N'2022-08-26' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(510.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (79, N'US079', CAST(N'2023-02-13' AS Date), CAST(N'2023-02-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (790, N'US0591', CAST(N'2022-08-12' AS Date), CAST(N'2022-08-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (791, N'US0592', CAST(N'2022-08-14' AS Date), CAST(N'2022-08-17' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(630.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (792, N'US0593', CAST(N'2022-08-17' AS Date), CAST(N'2022-08-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (793, N'US0594', CAST(N'2022-08-18' AS Date), CAST(N'2022-08-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (794, N'US0595', CAST(N'2022-08-11' AS Date), CAST(N'2022-08-15' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (795, N'US0596', CAST(N'2022-08-13' AS Date), CAST(N'2022-08-14' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (796, N'US0597', CAST(N'2022-08-20' AS Date), CAST(N'2022-08-21' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(160.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (797, N'US0598', CAST(N'2022-08-19' AS Date), CAST(N'2022-08-23' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (798, N'US0599', CAST(N'2022-08-22' AS Date), CAST(N'2022-08-23' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(180.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (799, N'US0201', CAST(N'2022-09-12' AS Date), CAST(N'2022-09-14' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (8, N'US08', CAST(N'2023-01-15' AS Date), CAST(N'2023-01-18' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (80, N'US080', CAST(N'2023-02-10' AS Date), CAST(N'2023-02-13' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(2490.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (800, N'US0202', CAST(N'2022-09-24' AS Date), CAST(N'2022-09-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(510.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (801, N'US0203', CAST(N'2022-09-13' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2430.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (802, N'US0204', CAST(N'2022-09-15' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (803, N'US0205', CAST(N'2022-09-22' AS Date), CAST(N'2022-09-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (804, N'US0206', CAST(N'2022-09-20' AS Date), CAST(N'2022-09-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (805, N'US0207', CAST(N'2022-09-16' AS Date), CAST(N'2022-09-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (806, N'US0208', CAST(N'2022-09-12' AS Date), CAST(N'2022-09-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (807, N'US0209', CAST(N'2022-09-17' AS Date), CAST(N'2022-09-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (808, N'US0210', CAST(N'2022-09-18' AS Date), CAST(N'2022-09-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (809, N'US0211', CAST(N'2022-09-16' AS Date), CAST(N'2022-09-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (81, N'US081', CAST(N'2023-02-12' AS Date), CAST(N'2023-02-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (810, N'US0212', CAST(N'2022-09-19' AS Date), CAST(N'2022-09-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1740.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (811, N'US0213', CAST(N'2022-09-14' AS Date), CAST(N'2022-09-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (812, N'US0214', CAST(N'2022-09-18' AS Date), CAST(N'2022-09-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (813, N'US0215', CAST(N'2022-09-13' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1770.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (814, N'US0216', CAST(N'2022-09-16' AS Date), CAST(N'2022-09-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(850.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (815, N'US0217', CAST(N'2022-09-23' AS Date), CAST(N'2022-09-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (816, N'US0218', CAST(N'2022-09-17' AS Date), CAST(N'2022-09-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(590.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (817, N'US0219', CAST(N'2022-09-14' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (818, N'US0220', CAST(N'2022-09-14' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (819, N'US0221', CAST(N'2022-09-15' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(620.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (82, N'US082', CAST(N'2023-02-17' AS Date), CAST(N'2023-02-21' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(2080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (820, N'US0222', CAST(N'2022-09-13' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1980.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (821, N'US0223', CAST(N'2022-09-12' AS Date), CAST(N'2022-09-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (822, N'US0224', CAST(N'2022-09-21' AS Date), CAST(N'2022-09-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(620.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (823, N'US0225', CAST(N'2022-09-19' AS Date), CAST(N'2022-09-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1590.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (824, N'US0226', CAST(N'2022-09-16' AS Date), CAST(N'2022-09-19' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (825, N'US0227', CAST(N'2022-09-18' AS Date), CAST(N'2022-09-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1420.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (826, N'US0228', CAST(N'2022-09-19' AS Date), CAST(N'2022-09-23' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (827, N'US0229', CAST(N'2022-09-15' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (828, N'US0230', CAST(N'2022-09-21' AS Date), CAST(N'2022-09-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (829, N'US0231', CAST(N'2022-09-19' AS Date), CAST(N'2022-09-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(630.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (83, N'US083', CAST(N'2023-02-14' AS Date), CAST(N'2023-02-16' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (830, N'US0232', CAST(N'2022-09-12' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (831, N'US0233', CAST(N'2022-09-22' AS Date), CAST(N'2022-09-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2580.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (832, N'US0234', CAST(N'2022-09-13' AS Date), CAST(N'2022-09-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (833, N'US0235', CAST(N'2022-09-13' AS Date), CAST(N'2022-09-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (834, N'US0236', CAST(N'2022-09-22' AS Date), CAST(N'2022-09-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (835, N'US0237', CAST(N'2022-09-16' AS Date), CAST(N'2022-09-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (836, N'US0238', CAST(N'2022-09-24' AS Date), CAST(N'2022-09-26' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (837, N'US0239', CAST(N'2022-09-19' AS Date), CAST(N'2022-09-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2490.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (838, N'US0240', CAST(N'2022-09-22' AS Date), CAST(N'2022-09-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (839, N'US0241', CAST(N'2022-09-10' AS Date), CAST(N'2022-09-13' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2550.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (84, N'US084', CAST(N'2023-02-21' AS Date), CAST(N'2023-02-25' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (840, N'US0242', CAST(N'2022-09-15' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(420.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (841, N'US0243', CAST(N'2022-09-14' AS Date), CAST(N'2022-09-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (842, N'US0244', CAST(N'2022-09-15' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(250.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (843, N'US0245', CAST(N'2022-09-14' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (844, N'US0246', CAST(N'2022-09-22' AS Date), CAST(N'2022-09-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2130.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (845, N'US0247', CAST(N'2022-09-22' AS Date), CAST(N'2022-09-26' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (846, N'US0248', CAST(N'2022-09-13' AS Date), CAST(N'2022-09-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (847, N'US0249', CAST(N'2022-09-24' AS Date), CAST(N'2022-09-26' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (848, N'US0250', CAST(N'2022-09-21' AS Date), CAST(N'2022-09-24' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1770.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (849, N'US0251', CAST(N'2022-09-11' AS Date), CAST(N'2022-09-14' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (85, N'US085', CAST(N'2023-02-12' AS Date), CAST(N'2023-02-14' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(580.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (850, N'US0252', CAST(N'2022-09-13' AS Date), CAST(N'2022-09-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2820.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (851, N'US0253', CAST(N'2022-09-21' AS Date), CAST(N'2022-09-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(450.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (852, N'US0254', CAST(N'2022-09-20' AS Date), CAST(N'2022-09-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (853, N'US0255', CAST(N'2022-09-12' AS Date), CAST(N'2022-09-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (854, N'US0256', CAST(N'2022-09-20' AS Date), CAST(N'2022-09-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (855, N'US0257', CAST(N'2022-09-15' AS Date), CAST(N'2022-09-18' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (856, N'US0258', CAST(N'2022-09-24' AS Date), CAST(N'2022-09-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (857, N'US0259', CAST(N'2022-09-16' AS Date), CAST(N'2022-09-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(300.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (858, N'US0260', CAST(N'2022-10-12' AS Date), CAST(N'2022-10-14' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (859, N'US0261', CAST(N'2022-10-24' AS Date), CAST(N'2022-10-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (86, N'US086', CAST(N'2023-02-24' AS Date), CAST(N'2023-02-26' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(940.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (860, N'US0262', CAST(N'2022-10-13' AS Date), CAST(N'2022-10-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2430.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (861, N'US0263', CAST(N'2022-10-15' AS Date), CAST(N'2022-10-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(670.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (862, N'US0264', CAST(N'2022-10-22' AS Date), CAST(N'2022-10-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (863, N'US0265', CAST(N'2022-10-20' AS Date), CAST(N'2022-10-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (864, N'US0266', CAST(N'2022-10-16' AS Date), CAST(N'2022-10-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (865, N'US0267', CAST(N'2022-10-12' AS Date), CAST(N'2022-10-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (866, N'US0268', CAST(N'2022-10-17' AS Date), CAST(N'2022-10-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (867, N'US0269', CAST(N'2022-10-18' AS Date), CAST(N'2022-10-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (868, N'US0270', CAST(N'2022-10-16' AS Date), CAST(N'2022-10-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (869, N'US0271', CAST(N'2022-10-19' AS Date), CAST(N'2022-10-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (87, N'US087', CAST(N'2023-02-13' AS Date), CAST(N'2023-02-15' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (870, N'US0272', CAST(N'2022-10-14' AS Date), CAST(N'2022-10-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2360.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (871, N'US0273', CAST(N'2022-10-18' AS Date), CAST(N'2022-10-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1530.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (872, N'US0274', CAST(N'2022-10-13' AS Date), CAST(N'2022-10-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (873, N'US0275', CAST(N'2022-10-16' AS Date), CAST(N'2022-10-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (874, N'US0276', CAST(N'2022-10-23' AS Date), CAST(N'2022-10-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(820.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (875, N'US0277', CAST(N'2022-10-17' AS Date), CAST(N'2022-10-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (876, N'US0278', CAST(N'2022-10-14' AS Date), CAST(N'2022-10-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (877, N'US0279', CAST(N'2022-10-14' AS Date), CAST(N'2022-10-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(780.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (878, N'US0280', CAST(N'2022-10-15' AS Date), CAST(N'2022-10-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(700.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (879, N'US0281', CAST(N'2022-10-13' AS Date), CAST(N'2022-10-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2100.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (88, N'US088', CAST(N'2023-02-20' AS Date), CAST(N'2023-02-23' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (880, N'US0282', CAST(N'2022-10-12' AS Date), CAST(N'2022-10-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (881, N'US0283', CAST(N'2022-10-21' AS Date), CAST(N'2022-10-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (882, N'US0284', CAST(N'2022-10-19' AS Date), CAST(N'2022-10-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1290.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (883, N'US0285', CAST(N'2022-10-16' AS Date), CAST(N'2022-10-19' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (884, N'US0286', CAST(N'2022-10-18' AS Date), CAST(N'2022-10-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(460.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (885, N'US0287', CAST(N'2022-10-19' AS Date), CAST(N'2022-10-23' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (886, N'US0288', CAST(N'2022-10-15' AS Date), CAST(N'2022-10-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (887, N'US0289', CAST(N'2022-10-21' AS Date), CAST(N'2022-10-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (888, N'US0290', CAST(N'2022-10-19' AS Date), CAST(N'2022-10-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(620.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (889, N'US0291', CAST(N'2022-10-12' AS Date), CAST(N'2022-10-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3080.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (89, N'US089', CAST(N'2023-02-21' AS Date), CAST(N'2023-02-22' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(400.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (890, N'US0292', CAST(N'2022-10-22' AS Date), CAST(N'2022-10-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2370.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (891, N'US0293', CAST(N'2022-10-13' AS Date), CAST(N'2022-10-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1060.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (892, N'US0294', CAST(N'2022-10-13' AS Date), CAST(N'2022-10-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1640.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (893, N'US0295', CAST(N'2022-11-12' AS Date), CAST(N'2022-11-14' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (894, N'US0296', CAST(N'2022-11-24' AS Date), CAST(N'2022-11-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (895, N'US0297', CAST(N'2022-11-13' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1590.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (896, N'US0298', CAST(N'2022-11-15' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(270.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (897, N'US0299', CAST(N'2022-11-22' AS Date), CAST(N'2022-11-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (898, N'US0300', CAST(N'2022-11-20' AS Date), CAST(N'2022-11-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (899, N'US0301', CAST(N'2022-11-16' AS Date), CAST(N'2022-11-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2480.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (9, N'US09', CAST(N'2023-01-13' AS Date), CAST(N'2023-01-17' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(1880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (90, N'US090', CAST(N'2023-02-24' AS Date), CAST(N'2023-02-27' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (900, N'US0302', CAST(N'2022-11-12' AS Date), CAST(N'2022-11-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (901, N'US0303', CAST(N'2022-11-17' AS Date), CAST(N'2022-11-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(420.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (902, N'US0304', CAST(N'2022-11-18' AS Date), CAST(N'2022-11-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(300.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (903, N'US0305', CAST(N'2022-11-16' AS Date), CAST(N'2022-11-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (904, N'US0306', CAST(N'2022-11-19' AS Date), CAST(N'2022-11-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1740.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (905, N'US0307', CAST(N'2022-11-14' AS Date), CAST(N'2022-11-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (906, N'US0308', CAST(N'2022-11-18' AS Date), CAST(N'2022-11-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1770.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (907, N'US0309', CAST(N'2022-11-13' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1590.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (908, N'US0310', CAST(N'2022-11-16' AS Date), CAST(N'2022-11-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(590.00 AS Decimal(10, 2)))
GO
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (909, N'US0311', CAST(N'2022-11-23' AS Date), CAST(N'2022-11-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1020.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (91, N'US091', CAST(N'2023-02-13' AS Date), CAST(N'2023-02-14' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(250.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (910, N'US0312', CAST(N'2022-11-17' AS Date), CAST(N'2022-11-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (911, N'US0313', CAST(N'2022-11-14' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1280.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (912, N'US0314', CAST(N'2022-11-14' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (913, N'US0315', CAST(N'2022-11-15' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (914, N'US0316', CAST(N'2022-11-13' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1650.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (915, N'US0317', CAST(N'2022-11-12' AS Date), CAST(N'2022-11-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(580.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (916, N'US0318', CAST(N'2022-11-21' AS Date), CAST(N'2022-11-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (917, N'US0319', CAST(N'2022-11-19' AS Date), CAST(N'2022-11-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2580.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (918, N'US0320', CAST(N'2022-11-16' AS Date), CAST(N'2022-11-19' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1110.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (919, N'US0321', CAST(N'2022-11-18' AS Date), CAST(N'2022-11-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(860.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (92, N'US092', CAST(N'2023-02-15' AS Date), CAST(N'2023-02-18' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(1200.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (920, N'US0322', CAST(N'2022-11-19' AS Date), CAST(N'2022-11-23' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1840.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (921, N'US0323', CAST(N'2022-11-15' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(230.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (922, N'US0324', CAST(N'2022-11-21' AS Date), CAST(N'2022-11-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(890.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (923, N'US0325', CAST(N'2022-11-19' AS Date), CAST(N'2022-11-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (924, N'US0326', CAST(N'2022-11-12' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (925, N'US0327', CAST(N'2022-11-22' AS Date), CAST(N'2022-11-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2040.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (926, N'US0328', CAST(N'2022-11-13' AS Date), CAST(N'2022-11-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (927, N'US0329', CAST(N'2022-11-13' AS Date), CAST(N'2022-11-17' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1120.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (928, N'US0330', CAST(N'2022-11-22' AS Date), CAST(N'2022-11-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (929, N'US0331', CAST(N'2022-11-16' AS Date), CAST(N'2022-11-18' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(900.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (93, N'US093', CAST(N'2023-02-20' AS Date), CAST(N'2023-02-23' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(1470.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (930, N'US0332', CAST(N'2022-11-24' AS Date), CAST(N'2022-11-26' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1380.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (931, N'US0333', CAST(N'2022-11-19' AS Date), CAST(N'2022-11-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1050.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (932, N'US0334', CAST(N'2022-11-22' AS Date), CAST(N'2022-11-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1180.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (933, N'US0335', CAST(N'2022-11-10' AS Date), CAST(N'2022-11-13' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (934, N'US0336', CAST(N'2022-11-15' AS Date), CAST(N'2022-11-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(750.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (935, N'US0337', CAST(N'2022-11-14' AS Date), CAST(N'2022-11-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (936, N'US0597', CAST(N'2022-12-12' AS Date), CAST(N'2022-12-14' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1680.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (937, N'US0598', CAST(N'2022-12-24' AS Date), CAST(N'2022-12-25' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(710.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (938, N'US0599', CAST(N'2022-12-13' AS Date), CAST(N'2022-12-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1500.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (939, N'US0600', CAST(N'2022-12-15' AS Date), CAST(N'2022-12-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(530.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (94, N'US094', CAST(N'2023-02-19' AS Date), CAST(N'2023-02-20' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(220.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (940, N'US0601', CAST(N'2022-12-22' AS Date), CAST(N'2022-12-24' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1020.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (941, N'US0602', CAST(N'2022-12-20' AS Date), CAST(N'2022-12-24' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(3320.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (942, N'US0603', CAST(N'2022-12-16' AS Date), CAST(N'2022-12-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (943, N'US0604', CAST(N'2022-12-12' AS Date), CAST(N'2022-12-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (944, N'US0605', CAST(N'2022-12-17' AS Date), CAST(N'2022-12-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (945, N'US0606', CAST(N'2022-12-18' AS Date), CAST(N'2022-12-19' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (946, N'US0607', CAST(N'2022-12-16' AS Date), CAST(N'2022-12-20' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (947, N'US0608', CAST(N'2022-12-19' AS Date), CAST(N'2022-12-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1710.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (948, N'US0609', CAST(N'2022-12-14' AS Date), CAST(N'2022-12-18' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1560.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (949, N'US0610', CAST(N'2022-12-18' AS Date), CAST(N'2022-12-21' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (95, N'US095', CAST(N'2023-02-19' AS Date), CAST(N'2023-02-21' AS Date), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(N'2022-12-02T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(340.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (950, N'US0611', CAST(N'2022-12-13' AS Date), CAST(N'2022-12-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1950.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (951, N'US0612', CAST(N'2022-12-16' AS Date), CAST(N'2022-12-17' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (952, N'US0613', CAST(N'2022-12-23' AS Date), CAST(N'2022-12-25' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1660.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (953, N'US0614', CAST(N'2022-12-17' AS Date), CAST(N'2022-12-18' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(510.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (954, N'US0615', CAST(N'2022-12-14' AS Date), CAST(N'2022-12-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (955, N'US0616', CAST(N'2022-12-14' AS Date), CAST(N'2022-12-16' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(880.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (956, N'US0617', CAST(N'2022-12-15' AS Date), CAST(N'2022-12-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(650.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (957, N'US0618', CAST(N'2022-12-13' AS Date), CAST(N'2022-12-16' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (958, N'US0619', CAST(N'2022-12-12' AS Date), CAST(N'2022-12-13' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(600.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (959, N'US0620', CAST(N'2022-12-21' AS Date), CAST(N'2022-12-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(800.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (96, N'US096', CAST(N'2023-02-18' AS Date), CAST(N'2023-02-21' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.20 AS Decimal(5, 2)), CAST(570.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (960, N'US0621', CAST(N'2022-12-19' AS Date), CAST(N'2022-12-22' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1920.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (961, N'US0622', CAST(N'2022-12-16' AS Date), CAST(N'2022-12-19' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2040.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (962, N'US0623', CAST(N'2022-12-18' AS Date), CAST(N'2022-12-20' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(540.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (963, N'US0624', CAST(N'2022-12-19' AS Date), CAST(N'2022-12-23' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1440.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (964, N'US0625', CAST(N'2022-12-15' AS Date), CAST(N'2022-12-16' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(520.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (965, N'US0626', CAST(N'2022-12-21' AS Date), CAST(N'2022-12-22' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(690.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (966, N'US0627', CAST(N'2022-12-19' AS Date), CAST(N'2022-12-20' AS Date), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(N'2021-12-01T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(620.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (967, N'US0628', CAST(N'2022-12-12' AS Date), CAST(N'2022-12-16' AS Date), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(N'2021-12-04T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(2000.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (968, N'US0629', CAST(N'2022-12-22' AS Date), CAST(N'2022-12-25' AS Date), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(N'2021-12-03T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(1410.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (969, N'US0630', CAST(N'2022-12-13' AS Date), CAST(N'2022-12-15' AS Date), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(N'2021-12-02T00:00:00.000' AS DateTime), CAST(0.00 AS Decimal(5, 2)), CAST(720.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (97, N'US097', CAST(N'2023-02-12' AS Date), CAST(N'2023-02-16' AS Date), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(N'2022-12-04T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(760.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (98, N'US098', CAST(N'2023-02-23' AS Date), CAST(N'2023-02-24' AS Date), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), CAST(0.10 AS Decimal(5, 2)), CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[Reservation] ([ID], [UsersId], [StartDate], [EndDate], [TsCreated], [TsUpdated], [DiscountPercent], [TotalPrice]) VALUES (99, N'US099', CAST(N'2023-02-12' AS Date), CAST(N'2023-02-15' AS Date), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(N'2022-12-03T00:00:00.000' AS DateTime), CAST(0.15 AS Decimal(5, 2)), CAST(960.00 AS Decimal(10, 2)))
SET IDENTITY_INSERT [dbo].[Reservation] OFF
GO
SET IDENTITY_INSERT [dbo].[ReservationStatus] ON 

INSERT [dbo].[ReservationStatus] ([ID], [StatusName]) VALUES (1, N'Pending')
INSERT [dbo].[ReservationStatus] ([ID], [StatusName]) VALUES (2, N'Confirmed')
INSERT [dbo].[ReservationStatus] ([ID], [StatusName]) VALUES (3, N'Cancelled')
INSERT [dbo].[ReservationStatus] ([ID], [StatusName]) VALUES (4, N'Completed')
INSERT [dbo].[ReservationStatus] ([ID], [StatusName]) VALUES (5, N'Expired')
SET IDENTITY_INSERT [dbo].[ReservationStatus] OFF
GO
SET IDENTITY_INSERT [dbo].[ReservationStatusEvents] ON 

INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (1, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV01')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (10, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV010')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (100, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0100')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (101, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0101')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (102, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0102')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (103, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0103')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (104, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0104')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (105, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0105')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (106, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0106')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (107, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0107')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (108, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0108')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (109, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0109')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (11, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV011')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (110, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0110')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (111, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0111')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (112, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0112')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (113, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0113')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (114, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0114')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (115, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0115')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (116, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0116')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (117, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0117')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (118, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0118')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (119, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0119')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (12, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV012')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (120, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0120')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (121, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0121')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (122, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0122')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (123, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0123')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (124, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0124')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (125, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0125')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (126, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0126')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (127, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0127')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (128, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0128')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (129, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0129')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (13, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV013')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (130, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0130')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (131, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0131')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (132, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0132')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (133, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0133')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (134, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0134')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (135, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0135')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (136, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0136')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (137, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0137')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (138, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0138')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (139, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0139')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (14, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV014')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (140, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0140')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (141, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0141')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (142, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0142')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (143, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0143')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (144, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0144')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (145, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0145')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (146, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0146')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (147, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0147')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (148, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0148')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (149, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0149')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (15, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV015')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (150, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0150')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (151, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0151')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (152, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0152')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (153, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0153')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (154, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0154')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (155, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0155')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (156, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0156')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (157, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0157')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (158, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0158')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (159, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0159')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (16, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV016')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (160, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0160')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (161, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0161')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (162, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0162')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (163, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0163')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (164, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0164')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (165, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0165')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (166, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0166')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (167, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0167')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (168, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0168')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (169, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0169')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (17, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV017')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (170, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0170')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (171, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0171')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (172, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0172')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (173, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0173')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (174, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0174')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (175, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0175')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (176, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0176')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (177, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0177')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (178, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0178')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (179, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0179')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (18, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV018')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (180, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0180')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (181, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0181')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (182, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0182')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (183, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0183')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (184, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0184')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (185, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0185')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (186, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0186')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (187, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0187')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (188, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0188')
GO
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (189, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0189')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (19, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV019')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (190, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0190')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (191, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0191')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (192, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0192')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (193, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0193')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (194, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0194')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (195, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0195')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (196, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0196')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (197, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0197')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (198, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0198')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (199, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0199')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (2, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV02')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (20, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV020')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (200, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0200')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (201, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0201')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (202, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0202')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (203, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0203')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (204, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0204')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (205, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0205')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (206, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0206')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (207, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0207')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (208, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0208')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (209, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0209')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (21, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV021')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (210, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0210')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (211, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0211')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (212, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0212')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (213, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0213')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (214, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0214')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (215, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0215')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (216, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0216')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (217, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0217')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (218, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0218')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (219, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0219')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (22, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV022')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (220, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0220')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (221, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0221')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (222, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0222')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (223, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0223')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (224, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0224')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (225, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0225')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (226, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0226')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (227, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0227')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (228, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0228')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (229, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0229')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (23, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV023')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (230, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0230')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (231, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0231')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (232, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0232')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (233, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0233')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (234, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0234')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (235, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0235')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (236, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0236')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (237, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0237')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (238, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0238')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (239, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0239')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (24, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV024')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (240, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0240')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (241, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0241')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (242, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0242')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (243, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0243')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (244, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0244')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (245, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0245')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (246, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0246')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (247, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0247')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (248, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0248')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (249, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0249')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (25, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV025')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (250, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0250')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (251, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0251')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (252, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0252')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (253, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0253')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (254, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0254')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (255, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0255')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (256, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0256')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (257, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0257')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (258, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0258')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (259, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0259')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (26, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV026')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (260, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0260')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (261, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0261')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (262, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0262')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (263, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0263')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (264, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0264')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (265, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0265')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (266, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0266')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (267, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0267')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (268, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0268')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (269, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0269')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (27, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV027')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (270, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0270')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (271, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0271')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (272, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0272')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (273, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0273')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (274, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0274')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (275, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0275')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (276, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0276')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (277, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0277')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (278, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0278')
GO
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (279, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0279')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (28, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV028')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (280, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0280')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (281, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0281')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (282, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0282')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (283, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0283')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (284, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0284')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (285, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0285')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (286, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0286')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (287, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0287')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (288, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0288')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (289, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0289')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (29, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV029')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (290, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0290')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (291, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0291')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (292, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0292')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (293, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0293')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (294, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0294')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (295, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0295')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (296, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0296')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (297, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0297')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (298, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0298')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (299, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0299')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (3, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV03')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (30, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV030')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (300, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0300')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (301, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0301')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (302, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0302')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (303, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0303')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (304, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0304')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (305, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0305')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (306, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0306')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (307, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0307')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (308, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0308')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (309, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0309')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (31, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV031')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (310, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0310')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (311, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0311')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (312, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0312')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (313, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0313')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (314, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0314')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (315, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0315')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (316, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0316')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (317, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0317')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (318, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0318')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (319, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0319')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (32, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV032')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (320, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0320')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (321, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0321')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (322, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0322')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (323, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0323')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (324, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0324')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (325, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0325')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (326, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0326')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (327, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0327')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (328, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0328')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (329, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0329')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (33, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV033')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (330, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0330')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (331, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0331')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (332, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0332')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (333, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0333')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (334, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0334')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (335, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0335')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (336, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0336')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (337, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0337')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (338, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0338')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (339, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0339')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (34, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV034')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (340, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0340')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (341, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0341')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (342, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0342')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (343, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0343')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (344, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0344')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (345, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0345')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (346, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0346')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (347, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0347')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (348, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0348')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (349, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0349')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (35, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV035')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (350, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0350')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (351, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0351')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (352, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0352')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (353, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0353')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (354, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0354')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (355, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0355')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (356, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0356')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (357, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0357')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (358, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0358')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (359, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0359')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (36, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV036')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (360, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0360')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (361, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0361')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (362, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0362')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (363, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0363')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (364, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0364')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (365, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0365')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (366, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0366')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (367, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0367')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (368, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0368')
GO
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (369, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0369')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (37, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV037')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (370, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0370')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (371, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0371')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (372, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0372')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (373, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0373')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (374, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0374')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (375, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0375')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (376, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0376')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (377, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0377')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (378, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0378')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (379, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0379')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (38, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV038')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (380, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0380')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (381, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0381')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (382, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0382')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (383, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0383')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (384, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0384')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (385, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0385')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (386, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0386')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (387, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0387')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (388, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0388')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (389, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0389')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (39, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV039')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (390, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0390')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (391, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0391')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (392, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0392')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (393, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0393')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (394, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0394')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (395, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0395')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (396, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0396')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (397, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0397')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (398, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0398')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (399, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0399')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (4, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV04')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (40, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV040')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (400, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0400')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (401, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0401')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (402, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0402')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (403, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0403')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (404, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0404')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (405, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0405')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (406, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0406')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (407, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0407')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (408, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0408')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (409, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0409')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (41, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV041')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (410, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0410')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (411, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0411')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (412, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0412')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (413, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0413')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (414, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0414')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (415, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0415')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (416, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0416')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (417, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0417')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (418, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0418')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (419, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0419')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (42, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV042')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (420, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0420')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (421, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0421')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (422, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0422')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (423, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0423')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (424, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0424')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (425, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0425')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (426, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0426')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (427, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0427')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (428, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0428')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (429, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0429')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (43, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV043')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (430, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0430')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (431, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0431')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (432, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0432')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (433, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0433')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (434, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0434')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (435, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0435')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (436, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0436')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (437, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0437')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (438, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0438')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (439, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0439')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (44, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV044')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (440, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0440')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (441, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0441')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (442, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0442')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (443, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0443')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (444, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0444')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (445, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0445')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (446, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0446')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (447, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0447')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (448, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0448')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (449, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0449')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (45, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV045')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (450, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0450')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (451, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0451')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (452, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0452')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (453, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0453')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (454, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0454')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (455, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0455')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (456, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0456')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (457, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0457')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (458, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0458')
GO
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (459, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0459')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (46, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV046')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (460, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0460')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (461, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0461')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (462, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0462')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (463, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0463')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (464, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0464')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (465, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0465')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (466, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0466')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (467, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0467')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (468, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0468')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (469, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0469')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (47, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV047')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (470, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0470')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (471, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0471')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (472, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0472')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (473, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0473')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (474, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0474')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (475, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0475')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (476, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0476')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (477, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0477')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (478, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0478')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (479, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0479')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (48, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV048')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (480, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0480')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (481, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0481')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (482, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0482')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (483, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0483')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (484, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0484')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (485, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0485')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (486, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0486')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (487, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0487')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (488, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0488')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (489, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0489')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (49, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV049')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (490, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0490')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (491, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0491')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (492, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0492')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (493, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0493')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (494, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0494')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (495, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0495')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (496, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0496')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (497, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0497')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (498, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0498')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (499, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0499')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (5, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV05')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (50, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV050')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (500, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0500')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (501, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0501')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (502, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0502')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (503, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0503')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (504, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0504')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (505, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0505')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (506, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0506')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (507, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0507')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (508, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0508')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (509, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0509')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (51, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV051')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (510, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0510')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (511, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0511')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (512, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0512')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (513, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0513')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (514, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0514')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (515, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0515')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (516, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0516')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (517, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0517')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (518, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0518')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (519, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0519')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (52, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV052')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (520, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0520')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (521, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0521')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (522, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0522')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (523, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0523')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (524, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0524')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (525, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0525')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (526, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0526')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (527, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0527')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (528, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0528')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (529, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0529')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (53, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV053')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (530, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0530')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (531, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0531')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (532, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0532')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (533, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0533')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (534, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0534')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (535, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0535')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (536, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0536')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (537, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0537')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (538, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0538')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (539, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0539')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (54, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV054')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (540, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0540')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (541, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0541')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (542, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0542')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (543, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0543')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (544, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0544')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (545, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0545')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (546, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0546')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (547, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0547')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (548, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0548')
GO
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (549, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0549')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (55, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV055')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (550, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0550')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (551, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0551')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (552, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0552')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (553, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0553')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (554, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0554')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (555, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0555')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (556, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0556')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (557, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0557')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (558, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0558')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (559, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0559')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (56, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV056')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (560, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0560')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (561, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0561')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (562, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0562')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (563, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0563')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (564, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0564')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (565, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0565')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (566, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0566')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (567, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0567')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (568, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0568')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (569, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0569')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (57, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV057')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (570, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0570')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (571, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0571')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (572, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0572')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (573, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0573')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (574, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0574')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (575, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0575')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (576, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0576')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (577, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0577')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (578, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0578')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (579, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0579')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (58, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV058')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (580, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0580')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (581, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0581')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (582, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0582')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (583, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0583')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (584, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0584')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (585, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0585')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (586, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0586')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (587, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0587')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (588, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0588')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (589, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0589')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (59, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV059')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (590, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0590')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (591, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0591')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (592, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0592')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (593, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0593')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (594, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0594')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (595, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0595')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (596, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0596')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (597, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0597')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (598, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0598')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (599, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0599')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (6, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV06')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (60, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV060')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (600, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0600')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (601, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0601')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (602, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0602')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (603, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0603')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (604, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0604')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (605, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0605')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (606, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0606')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (607, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0607')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (608, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0608')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (609, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0609')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (61, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV061')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (610, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0610')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (611, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0611')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (612, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0612')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (613, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0613')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (614, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0614')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (615, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0615')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (616, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0616')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (617, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0617')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (618, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0618')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (619, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0619')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (62, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV062')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (620, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0620')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (621, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0621')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (622, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0622')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (623, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0623')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (624, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0624')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (625, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0625')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (626, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0626')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (627, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0627')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (628, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0628')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (629, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0629')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (63, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV063')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (630, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0630')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (631, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0631')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (632, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0632')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (633, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0633')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (634, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0634')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (635, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0635')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (636, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0636')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (637, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0637')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (638, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0638')
GO
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (639, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0639')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (64, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV064')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (640, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0640')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (641, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0641')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (642, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0642')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (643, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0643')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (644, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0644')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (645, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0645')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (646, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0646')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (647, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0647')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (648, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0648')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (649, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0649')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (65, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV065')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (650, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0650')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (651, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0651')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (652, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0652')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (653, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0653')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (654, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0654')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (655, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0655')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (656, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0656')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (657, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0657')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (658, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0658')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (659, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0659')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (66, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV066')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (660, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0660')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (661, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0661')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (662, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0662')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (663, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0663')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (664, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0664')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (665, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0665')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (666, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0666')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (667, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0667')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (668, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0668')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (669, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0669')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (67, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV067')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (670, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0670')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (671, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0671')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (672, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0672')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (673, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0673')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (674, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0674')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (675, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0675')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (676, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0676')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (677, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0677')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (678, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0678')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (679, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0679')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (68, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV068')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (680, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0680')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (681, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0681')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (682, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0682')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (683, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0683')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (684, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0684')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (685, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0685')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (686, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0686')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (687, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0687')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (688, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0688')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (689, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0689')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (69, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV069')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (690, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0690')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (691, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0691')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (692, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0692')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (693, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0693')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (694, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0694')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (695, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0695')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (696, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0696')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (697, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0697')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (698, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0698')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (699, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0699')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (7, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV07')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (70, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV070')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (700, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0700')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (701, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0701')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (702, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0702')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (703, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0703')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (704, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0704')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (705, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0705')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (706, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0706')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (707, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0707')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (708, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0708')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (709, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0709')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (71, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV071')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (710, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0710')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (711, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0711')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (712, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0712')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (713, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0713')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (714, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0714')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (715, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0715')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (716, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0716')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (717, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0717')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (718, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0718')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (719, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0719')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (72, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV072')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (720, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0720')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (721, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0721')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (722, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0722')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (723, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0723')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (724, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0724')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (725, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0725')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (726, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0726')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (727, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0727')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (728, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0728')
GO
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (729, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0729')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (73, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV073')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (730, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0730')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (731, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0731')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (732, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0732')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (733, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0733')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (734, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0734')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (735, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0735')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (736, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0736')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (737, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0737')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (738, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0738')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (739, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0739')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (74, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV074')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (740, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0740')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (741, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0741')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (742, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0742')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (743, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0743')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (744, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0744')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (745, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0745')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (746, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0746')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (747, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0747')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (748, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0748')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (749, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0749')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (75, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV075')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (750, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0750')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (751, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0751')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (752, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0752')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (753, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0753')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (754, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0754')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (755, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0755')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (756, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0756')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (757, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0757')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (758, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0758')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (759, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0759')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (76, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV076')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (760, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0760')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (761, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0761')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (762, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0762')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (763, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0763')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (764, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0764')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (765, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0765')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (766, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0766')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (767, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0767')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (768, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0768')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (769, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0769')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (77, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV077')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (770, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0770')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (771, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0771')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (772, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0772')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (773, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0773')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (774, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0774')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (775, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0775')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (776, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0776')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (777, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0777')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (778, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0778')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (779, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0779')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (78, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV078')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (780, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0780')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (781, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0781')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (782, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0782')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (783, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0783')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (784, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0784')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (785, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0785')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (786, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0786')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (787, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0787')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (788, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0788')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (789, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0789')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (79, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV079')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (790, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0790')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (791, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0791')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (792, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0792')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (793, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0793')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (794, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0794')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (795, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0795')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (796, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0796')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (797, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0797')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (798, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0798')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (799, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0799')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (8, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV08')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (80, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV080')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (800, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0800')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (801, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0801')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (802, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0802')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (803, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0803')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (804, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0804')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (805, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0805')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (806, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0806')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (807, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0807')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (808, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0808')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (809, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0809')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (81, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV081')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (810, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0810')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (811, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0811')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (812, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0812')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (813, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0813')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (814, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0814')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (815, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0815')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (816, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0816')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (817, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0817')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (818, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0818')
GO
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (819, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0819')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (82, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV082')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (820, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0820')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (821, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0821')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (822, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0822')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (823, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0823')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (824, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0824')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (825, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0825')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (826, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0826')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (827, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0827')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (828, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0828')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (829, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0829')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (83, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV083')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (830, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0830')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (831, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0831')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (832, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0832')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (833, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0833')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (834, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0834')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (835, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0835')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (836, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0836')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (837, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0837')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (838, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0838')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (839, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0839')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (84, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV084')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (840, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0840')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (841, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0841')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (842, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0842')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (843, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0843')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (844, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0844')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (845, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0845')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (846, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0846')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (847, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0847')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (848, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0848')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (849, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0849')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (85, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV085')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (850, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0850')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (851, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0851')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (852, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0852')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (853, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0853')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (854, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0854')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (855, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0855')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (856, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0856')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (857, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0857')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (858, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0858')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (859, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0859')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (86, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV086')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (860, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0860')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (861, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0861')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (862, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0862')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (863, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0863')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (864, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0864')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (865, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0865')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (866, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0866')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (867, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0867')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (868, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0868')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (869, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0869')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (87, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV087')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (870, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0870')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (871, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0871')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (872, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0872')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (873, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0873')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (874, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0874')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (875, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0875')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (876, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0876')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (877, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0877')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (878, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0878')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (879, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0879')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (88, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV088')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (880, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0880')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (881, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0881')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (882, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0882')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (883, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0883')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (884, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0884')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (885, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0885')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (886, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0886')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (887, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0887')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (888, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0888')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (889, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0889')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (89, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV089')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (890, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0890')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (891, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0891')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (892, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0892')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (893, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0893')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (894, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0894')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (895, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0895')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (896, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0896')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (897, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0897')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (898, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0898')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (899, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0899')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (9, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV09')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (90, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV090')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (900, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0900')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (901, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0901')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (902, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0902')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (903, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0903')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (904, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0904')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (905, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0905')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (906, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0906')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (907, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0907')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (908, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0908')
GO
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (909, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0909')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (91, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV091')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (910, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0910')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (911, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0911')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (912, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0912')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (913, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0913')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (914, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0914')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (915, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0915')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (916, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0916')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (917, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0917')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (918, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0918')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (919, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0919')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (92, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV092')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (920, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0920')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (921, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0921')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (922, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0922')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (923, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0923')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (924, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0924')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (925, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0925')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (926, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0926')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (927, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0927')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (928, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0928')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (929, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0929')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (93, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV093')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (930, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0930')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (931, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0931')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (932, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0932')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (933, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0933')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (934, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0934')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (935, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0935')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (936, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0936')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (937, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0937')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (938, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0938')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (939, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0939')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (94, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV094')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (940, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0940')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (941, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0941')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (942, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0942')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (943, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0943')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (944, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0944')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (945, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0945')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (946, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0946')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (947, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0947')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (948, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0948')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (949, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0949')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (95, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV095')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (950, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0950')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (951, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0951')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (952, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0952')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (953, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0953')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (954, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0954')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (955, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0955')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (956, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0956')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (957, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0957')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (958, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0958')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (959, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0959')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (96, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV096')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (960, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0960')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (961, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0961')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (962, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0962')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (963, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0963')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (964, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0964')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (965, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0965')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (966, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0966')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (967, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0967')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (968, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0968')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (969, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV0969')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (97, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV097')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (98, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV098')
INSERT [dbo].[ReservationStatusEvents] ([ID], [RSETsCreated], [Details], [RSId], [ReservationId]) VALUES (99, CAST(N'2023-12-31T23:59:00.000' AS DateTime), N'Reservation fully completed', N'RS04', N'RV099')
SET IDENTITY_INSERT [dbo].[ReservationStatusEvents] OFF
GO
SET IDENTITY_INSERT [dbo].[Room] ON 

INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (1, N'HO01', N'RT05', N'Room 101', CAST(270.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (10, N'HO01', N'RT06', N'Room 401', CAST(480.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (100, N'HO010', N'RT06', N'Room 101', CAST(460.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (101, N'HO010', N'RT010', N'Room 102', CAST(250.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (102, N'HO010', N'RT012', N'Room 201', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (103, N'HO010', N'RT012', N'Room 202', CAST(100.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (104, N'HO010', N'RT08', N'Room 203', CAST(380.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (105, N'HO010', N'RT03', N'Room 204', CAST(170.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (106, N'HO010', N'RT013', N'Room 301', CAST(230.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (107, N'HO010', N'RT012', N'Room 302', CAST(160.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (108, N'HO010', N'RT03', N'Room 303', CAST(200.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (109, N'HO010', N'RT012', N'Room 401', CAST(450.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (11, N'HO01', N'RT012', N'Room 402', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (110, N'HO010', N'RT011', N'Room 402', CAST(130.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (111, N'HO011', N'RT02', N'Room 101', CAST(450.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (112, N'HO011', N'RT012', N'Room 102', CAST(390.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (113, N'HO011', N'RT08', N'Room 201', CAST(310.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (114, N'HO011', N'RT04', N'Room 202', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (115, N'HO011', N'RT05', N'Room 203', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (116, N'HO011', N'RT04', N'Room 204', CAST(410.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (117, N'HO011', N'RT012', N'Room 301', CAST(280.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (118, N'HO011', N'RT09', N'Room 302', CAST(230.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (119, N'HO011', N'RT013', N'Room 303', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (12, N'HO02', N'RT08', N'Room 101', CAST(340.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (120, N'HO011', N'RT015', N'Room 401', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (121, N'HO011', N'RT09', N'Room 402', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (122, N'HO012', N'RT015', N'Room 101', CAST(410.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (123, N'HO012', N'RT04', N'Room 102', CAST(450.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (124, N'HO012', N'RT06', N'Room 201', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (125, N'HO012', N'RT02', N'Room 202', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (126, N'HO012', N'RT03', N'Room 203', CAST(150.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (127, N'HO012', N'RT08', N'Room 204', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (128, N'HO012', N'RT012', N'Room 301', CAST(100.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (129, N'HO012', N'RT03', N'Room 302', CAST(270.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (13, N'HO02', N'RT011', N'Room 102', CAST(280.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (130, N'HO012', N'RT010', N'Room 303', CAST(170.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (131, N'HO012', N'RT013', N'Room 401', CAST(130.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (132, N'HO012', N'RT06', N'Room 402', CAST(350.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (133, N'HO013', N'RT04', N'Room 101', CAST(170.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (134, N'HO013', N'RT06', N'Room 102', CAST(300.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (135, N'HO013', N'RT03', N'Room 201', CAST(130.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (136, N'HO013', N'RT06', N'Room 202', CAST(370.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (137, N'HO013', N'RT03', N'Room 203', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (138, N'HO013', N'RT01', N'Room 204', CAST(330.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (139, N'HO013', N'RT014', N'Room 301', CAST(480.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (14, N'HO02', N'RT07', N'Room 201', CAST(130.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (140, N'HO013', N'RT07', N'Room 302', CAST(330.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (141, N'HO013', N'RT01', N'Room 303', CAST(130.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (142, N'HO013', N'RT012', N'Room 401', CAST(210.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (143, N'HO013', N'RT03', N'Room 402', CAST(290.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (144, N'HO014', N'RT011', N'Room 101', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (145, N'HO014', N'RT04', N'Room 102', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (146, N'HO014', N'RT011', N'Room 201', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (147, N'HO014', N'RT02', N'Room 202', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (148, N'HO014', N'RT03', N'Room 203', CAST(460.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (149, N'HO014', N'RT06', N'Room 204', CAST(140.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (15, N'HO02', N'RT04', N'Room 202', CAST(440.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (150, N'HO014', N'RT010', N'Room 301', CAST(400.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (151, N'HO014', N'RT012', N'Room 302', CAST(440.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (152, N'HO014', N'RT08', N'Room 303', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (153, N'HO014', N'RT014', N'Room 401', CAST(490.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (154, N'HO014', N'RT015', N'Room 402', CAST(400.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (155, N'HO015', N'RT015', N'Room 101', CAST(200.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (156, N'HO015', N'RT013', N'Room 102', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (157, N'HO015', N'RT011', N'Room 201', CAST(500.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (158, N'HO015', N'RT06', N'Room 202', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (159, N'HO015', N'RT014', N'Room 203', CAST(200.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (16, N'HO02', N'RT02', N'Room 203', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (160, N'HO015', N'RT010', N'Room 204', CAST(400.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (161, N'HO015', N'RT01', N'Room 301', CAST(400.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (162, N'HO015', N'RT015', N'Room 302', CAST(260.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (163, N'HO015', N'RT05', N'Room 303', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (164, N'HO015', N'RT06', N'Room 401', CAST(130.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (165, N'HO015', N'RT04', N'Room 402', CAST(480.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (166, N'HO016', N'RT02', N'Room 101', CAST(160.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (167, N'HO016', N'RT05', N'Room 102', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (168, N'HO016', N'RT02', N'Room 201', CAST(210.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (169, N'HO016', N'RT02', N'Room 202', CAST(410.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (17, N'HO02', N'RT03', N'Room 204', CAST(310.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (170, N'HO016', N'RT03', N'Room 203', CAST(250.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (171, N'HO016', N'RT01', N'Room 204', CAST(460.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (172, N'HO016', N'RT014', N'Room 301', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (173, N'HO016', N'RT03', N'Room 302', CAST(330.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (174, N'HO016', N'RT014', N'Room 303', CAST(370.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (175, N'HO016', N'RT011', N'Room 401', CAST(400.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (176, N'HO016', N'RT01', N'Room 402', CAST(480.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (177, N'HO017', N'RT09', N'Room 101', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (178, N'HO017', N'RT015', N'Room 102', CAST(150.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (179, N'HO017', N'RT09', N'Room 201', CAST(340.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (18, N'HO02', N'RT013', N'Room 301', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (180, N'HO017', N'RT06', N'Room 202', CAST(490.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (181, N'HO017', N'RT04', N'Room 203', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (182, N'HO017', N'RT01', N'Room 204', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (183, N'HO017', N'RT011', N'Room 301', CAST(140.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (184, N'HO017', N'RT011', N'Room 302', CAST(140.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (185, N'HO017', N'RT07', N'Room 303', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (186, N'HO017', N'RT013', N'Room 401', CAST(370.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (187, N'HO017', N'RT013', N'Room 402', CAST(420.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (188, N'HO018', N'RT07', N'Room 101', CAST(170.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
GO
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (189, N'HO018', N'RT08', N'Room 102', CAST(350.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (19, N'HO02', N'RT09', N'Room 302', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (190, N'HO018', N'RT07', N'Room 201', CAST(170.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (191, N'HO018', N'RT04', N'Room 202', CAST(250.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (192, N'HO018', N'RT06', N'Room 203', CAST(490.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (193, N'HO018', N'RT07', N'Room 204', CAST(450.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (194, N'HO018', N'RT013', N'Room 301', CAST(500.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (195, N'HO018', N'RT010', N'Room 302', CAST(190.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (196, N'HO018', N'RT015', N'Room 303', CAST(240.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (197, N'HO018', N'RT013', N'Room 401', CAST(210.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (198, N'HO018', N'RT011', N'Room 402', CAST(190.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (199, N'HO019', N'RT011', N'Room 101', CAST(210.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (2, N'HO01', N'RT05', N'Room 102', CAST(320.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (20, N'HO02', N'RT014', N'Room 303', CAST(280.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (200, N'HO019', N'RT03', N'Room 102', CAST(190.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (201, N'HO019', N'RT02', N'Room 201', CAST(430.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (202, N'HO019', N'RT06', N'Room 202', CAST(260.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (203, N'HO019', N'RT07', N'Room 203', CAST(450.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (204, N'HO019', N'RT014', N'Room 204', CAST(450.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (205, N'HO019', N'RT05', N'Room 301', CAST(240.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (206, N'HO019', N'RT015', N'Room 302', CAST(260.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (207, N'HO019', N'RT07', N'Room 303', CAST(170.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (208, N'HO019', N'RT011', N'Room 401', CAST(180.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (209, N'HO019', N'RT012', N'Room 402', CAST(210.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (21, N'HO02', N'RT06', N'Room 401', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (210, N'HO020', N'RT07', N'Room 101', CAST(320.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (211, N'HO020', N'RT03', N'Room 102', CAST(190.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (212, N'HO020', N'RT08', N'Room 201', CAST(280.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (213, N'HO020', N'RT013', N'Room 202', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (214, N'HO020', N'RT014', N'Room 203', CAST(160.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (215, N'HO020', N'RT06', N'Room 204', CAST(160.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (216, N'HO020', N'RT011', N'Room 301', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (217, N'HO020', N'RT03', N'Room 302', CAST(180.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (218, N'HO020', N'RT012', N'Room 303', CAST(180.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (219, N'HO020', N'RT06', N'Room 401', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (22, N'HO02', N'RT02', N'Room 402', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (220, N'HO020', N'RT010', N'Room 402', CAST(320.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (23, N'HO03', N'RT05', N'Room 101', CAST(140.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (24, N'HO03', N'RT01', N'Room 102', CAST(270.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (25, N'HO03', N'RT011', N'Room 201', CAST(150.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (26, N'HO03', N'RT07', N'Room 202', CAST(100.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (27, N'HO03', N'RT010', N'Room 203', CAST(320.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (28, N'HO03', N'RT05', N'Room 204', CAST(270.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (29, N'HO03', N'RT02', N'Room 301', CAST(420.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (3, N'HO01', N'RT08', N'Room 201', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (30, N'HO03', N'RT014', N'Room 302', CAST(420.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (31, N'HO03', N'RT012', N'Room 303', CAST(180.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (32, N'HO03', N'RT014', N'Room 401', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (33, N'HO03', N'RT010', N'Room 402', CAST(420.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (34, N'HO04', N'RT06', N'Room 101', CAST(460.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (35, N'HO04', N'RT010', N'Room 102', CAST(250.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (36, N'HO04', N'RT012', N'Room 201', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (37, N'HO04', N'RT012', N'Room 202', CAST(100.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (38, N'HO04', N'RT08', N'Room 203', CAST(380.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (39, N'HO04', N'RT03', N'Room 204', CAST(170.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (4, N'HO01', N'RT06', N'Room 202', CAST(160.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (40, N'HO04', N'RT013', N'Room 301', CAST(230.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (41, N'HO04', N'RT012', N'Room 302', CAST(160.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (42, N'HO04', N'RT03', N'Room 303', CAST(200.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (43, N'HO04', N'RT012', N'Room 401', CAST(450.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (44, N'HO04', N'RT011', N'Room 402', CAST(130.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (45, N'HO05', N'RT02', N'Room 101', CAST(450.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (46, N'HO05', N'RT012', N'Room 102', CAST(390.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (47, N'HO05', N'RT08', N'Room 201', CAST(310.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (48, N'HO05', N'RT04', N'Room 202', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (49, N'HO05', N'RT05', N'Room 203', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (5, N'HO01', N'RT02', N'Room 203', CAST(270.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (50, N'HO05', N'RT04', N'Room 204', CAST(410.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (51, N'HO05', N'RT012', N'Room 301', CAST(280.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (52, N'HO05', N'RT09', N'Room 302', CAST(230.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (53, N'HO05', N'RT013', N'Room 303', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (54, N'HO05', N'RT015', N'Room 401', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (55, N'HO05', N'RT09', N'Room 402', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (56, N'HO06', N'RT07', N'Room 101', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (57, N'HO06', N'RT02', N'Room 102', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (58, N'HO06', N'RT011', N'Room 201', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (59, N'HO06', N'RT04', N'Room 202', CAST(460.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (6, N'HO01', N'RT03', N'Room 204', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (60, N'HO06', N'RT05', N'Room 203', CAST(390.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (61, N'HO06', N'RT09', N'Room 204', CAST(290.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (62, N'HO06', N'RT09', N'Room 301', CAST(240.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (63, N'HO06', N'RT08', N'Room 302', CAST(260.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (64, N'HO06', N'RT014', N'Room 303', CAST(480.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (65, N'HO06', N'RT03', N'Room 401', CAST(250.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (66, N'HO06', N'RT03', N'Room 402', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (67, N'HO07', N'RT05', N'Room 101', CAST(270.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (68, N'HO07', N'RT05', N'Room 102', CAST(320.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (69, N'HO07', N'RT08', N'Room 201', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (7, N'HO01', N'RT07', N'Room 301', CAST(340.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (70, N'HO07', N'RT06', N'Room 202', CAST(160.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (71, N'HO07', N'RT02', N'Room 203', CAST(270.00 AS Decimal(10, 2)), 1, 1, N'A cozy and comfortable executive suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (72, N'HO07', N'RT03', N'Room 204', CAST(120.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (73, N'HO07', N'RT07', N'Room 301', CAST(340.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (74, N'HO07', N'RT04', N'Room 302', CAST(170.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (75, N'HO07', N'RT07', N'Room 303', CAST(100.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (76, N'HO07', N'RT06', N'Room 401', CAST(480.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (77, N'HO07', N'RT012', N'Room 402', CAST(470.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (78, N'HO08', N'RT08', N'Room 101', CAST(340.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (79, N'HO08', N'RT011', N'Room 102', CAST(280.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (8, N'HO01', N'RT04', N'Room 302', CAST(170.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
GO
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (80, N'HO08', N'RT07', N'Room 201', CAST(130.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (81, N'HO08', N'RT04', N'Room 202', CAST(440.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (82, N'HO08', N'RT02', N'Room 203', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (83, N'HO08', N'RT03', N'Room 204', CAST(310.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (84, N'HO08', N'RT013', N'Room 301', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (85, N'HO08', N'RT09', N'Room 302', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (86, N'HO08', N'RT014', N'Room 303', CAST(280.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (87, N'HO08', N'RT06', N'Room 401', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (88, N'HO08', N'RT02', N'Room 402', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (89, N'HO09', N'RT08', N'Room 101', CAST(340.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (9, N'HO01', N'RT07', N'Room 303', CAST(100.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (90, N'HO09', N'RT011', N'Room 102', CAST(280.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (91, N'HO09', N'RT07', N'Room 201', CAST(130.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (92, N'HO09', N'RT04', N'Room 202', CAST(440.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (93, N'HO09', N'RT02', N'Room 203', CAST(220.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (94, N'HO09', N'RT03', N'Room 204', CAST(310.00 AS Decimal(10, 2)), 1, 1, N'A luxurious and sophisticated penthouse suite.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (95, N'HO09', N'RT013', N'Room 301', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A stylish and modern premium room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (96, N'HO09', N'RT09', N'Room 302', CAST(360.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (97, N'HO09', N'RT014', N'Room 303', CAST(280.00 AS Decimal(10, 2)), 1, 1, N'A charming and elegant standard room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (98, N'HO09', N'RT06', N'Room 401', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'A tranquil and peaceful garden view room.')
INSERT [dbo].[Room] ([ID], [HotelId], [RoomTypeId], [RoomName], [CurrentPrice], [IsAvailable], [IsActive], [Description]) VALUES (99, N'HO09', N'RT02', N'Room 402', CAST(110.00 AS Decimal(10, 2)), 1, 1, N'An upscale and spacious deluxe room.')
SET IDENTITY_INSERT [dbo].[Room] OFF
GO
SET IDENTITY_INSERT [dbo].[RoomReserved] ON 

INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1, N'RV01', N'RO04')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (10, N'RV07', N'RO029')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (100, N'RV061', N'RO049')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1000, N'RV0681', N'RO079')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1001, N'RV0682', N'RO080')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1002, N'RV0683', N'RO081')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1003, N'RV0684', N'RO083')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1004, N'RV0685', N'RO084')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1005, N'RV0686', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1006, N'RV0687', N'RO086')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1007, N'RV0688', N'RO087')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1008, N'RV0689', N'RO089')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1009, N'RV0690', N'RO090')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (101, N'RV062', N'RO052')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1010, N'RV0691', N'RO091')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1011, N'RV0692', N'RO092')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1012, N'RV0693', N'RO093')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1013, N'RV0694', N'RO094')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1014, N'RV0695', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1015, N'RV0696', N'RO097')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1016, N'RV0697', N'RO098')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1017, N'RV0698', N'RO099')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1018, N'RV0699', N'RO0100')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1019, N'RV0700', N'RO0101')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (102, N'RV062', N'RO053')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1020, N'RV0701', N'RO0103')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1021, N'RV0702', N'RO0104')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1022, N'RV0703', N'RO0105')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1023, N'RV0704', N'RO0106')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1024, N'RV0705', N'RO0107')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1025, N'RV0706', N'RO0109')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1026, N'RV0707', N'RO0110')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1027, N'RV0708', N'RO0111')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1028, N'RV0709', N'RO0112')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1029, N'RV0710', N'RO0113')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (103, N'RV063', N'RO056')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1030, N'RV0711', N'RO0114')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1031, N'RV0712', N'RO0116')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1032, N'RV0713', N'RO0117')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1033, N'RV0714', N'RO0118')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1034, N'RV0715', N'RO0119')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1035, N'RV0716', N'RO0120')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1036, N'RV0717', N'RO0122')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1037, N'RV0718', N'RO0123')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1038, N'RV0719', N'RO0124')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1039, N'RV0720', N'RO0125')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (104, N'RV063', N'RO057')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1040, N'RV0721', N'RO0126')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1041, N'RV0722', N'RO0127')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1042, N'RV0723', N'RO0129')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1043, N'RV0724', N'RO0130')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1044, N'RV0725', N'RO0131')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1045, N'RV0726', N'RO0132')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1046, N'RV0727', N'RO0133')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1047, N'RV0728', N'RO0135')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1048, N'RV0729', N'RO0136')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1049, N'RV0730', N'RO0137')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (105, N'RV064', N'RO060')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1050, N'RV0731', N'RO0138')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1051, N'RV0732', N'RO0139')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1052, N'RV0733', N'RO0140')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1053, N'RV0734', N'RO0142')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1054, N'RV0735', N'RO0143')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1055, N'RV0736', N'RO0144')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1056, N'RV0737', N'RO0145')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1057, N'RV0738', N'RO0146')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1058, N'RV0739', N'RO0148')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1059, N'RV0740', N'RO0149')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (106, N'RV064', N'RO061')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1060, N'RV0741', N'RO0150')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1061, N'RV0742', N'RO0151')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1062, N'RV0743', N'RO0152')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1063, N'RV0744', N'RO0153')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1064, N'RV0745', N'RO0155')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1065, N'RV0746', N'RO0156')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1066, N'RV0747', N'RO0157')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1067, N'RV0748', N'RO0158')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1068, N'RV0749', N'RO0159')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1069, N'RV0750', N'RO0160')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (107, N'RV065', N'RO064')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1070, N'RV0751', N'RO0162')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1071, N'RV0752', N'RO0163')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1072, N'RV0753', N'RO0164')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1073, N'RV0754', N'RO0165')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1074, N'RV0755', N'RO0166')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1075, N'RV0756', N'RO0168')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1076, N'RV0757', N'RO0169')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1077, N'RV0758', N'RO0170')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1078, N'RV0759', N'RO0171')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1079, N'RV0760', N'RO0172')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (108, N'RV065', N'RO065')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1080, N'RV0761', N'RO0173')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1081, N'RV0762', N'RO0175')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1082, N'RV0763', N'RO0176')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1083, N'RV0764', N'RO0177')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1084, N'RV0765', N'RO0178')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1085, N'RV0766', N'RO0179')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1086, N'RV0767', N'RO0181')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1087, N'RV0768', N'RO0182')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1088, N'RV0769', N'RO0183')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1089, N'RV0770', N'RO0184')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (109, N'RV066', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1090, N'RV0771', N'RO0185')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1091, N'RV0772', N'RO0186')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1092, N'RV0773', N'RO0188')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1093, N'RV0774', N'RO0189')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1094, N'RV0775', N'RO0190')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1095, N'RV0776', N'RO0191')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1096, N'RV0777', N'RO0192')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1097, N'RV0778', N'RO0194')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1098, N'RV0779', N'RO0195')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1099, N'RV0780', N'RO0196')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (11, N'RV08', N'RO032')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (110, N'RV066', N'RO069')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1100, N'RV0781', N'RO0197')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1101, N'RV0782', N'RO0198')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1102, N'RV0783', N'RO0199')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1103, N'RV0784', N'RO0201')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1104, N'RV0785', N'RO0202')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1105, N'RV0786', N'RO0203')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1106, N'RV0787', N'RO0204')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1107, N'RV0788', N'RO0205')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1108, N'RV0789', N'RO0207')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1109, N'RV0790', N'RO0208')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (111, N'RV067', N'RO072')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1110, N'RV0791', N'RO0209')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1111, N'RV0792', N'RO0210')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1112, N'RV0793', N'RO0211')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1113, N'RV0794', N'RO0212')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1114, N'RV0795', N'RO0214')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1115, N'RV0796', N'RO0215')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1116, N'RV0797', N'RO0216')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1117, N'RV0798', N'RO0217')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1118, N'RV0799', N'RO04')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1119, N'RV0799', N'RO05')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (112, N'RV067', N'RO073')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1120, N'RV0800', N'RO07')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1121, N'RV0800', N'RO08')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1122, N'RV0801', N'RO011')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1123, N'RV0801', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1124, N'RV0802', N'RO015')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1125, N'RV0802', N'RO016')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1126, N'RV0803', N'RO019')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1127, N'RV0803', N'RO020')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1128, N'RV0804', N'RO022')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1129, N'RV0804', N'RO023')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (113, N'RV068', N'RO076')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1130, N'RV0805', N'RO026')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1131, N'RV0805', N'RO027')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1132, N'RV0806', N'RO030')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1133, N'RV0806', N'RO031')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1134, N'RV0807', N'RO033')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1135, N'RV0807', N'RO034')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1136, N'RV0808', N'RO037')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1137, N'RV0808', N'RO038')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1138, N'RV0809', N'RO041')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1139, N'RV0809', N'RO042')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (114, N'RV068', N'RO077')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1140, N'RV0810', N'RO044')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1141, N'RV0810', N'RO045')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1142, N'RV0811', N'RO048')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1143, N'RV0811', N'RO049')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1144, N'RV0812', N'RO052')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1145, N'RV0812', N'RO053')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1146, N'RV0813', N'RO056')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1147, N'RV0813', N'RO057')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1148, N'RV0814', N'RO059')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1149, N'RV0814', N'RO060')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (115, N'RV069', N'RO080')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1150, N'RV0815', N'RO063')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1151, N'RV0815', N'RO064')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1152, N'RV0816', N'RO067')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1153, N'RV0816', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1154, N'RV0817', N'RO070')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1155, N'RV0817', N'RO071')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1156, N'RV0818', N'RO074')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1157, N'RV0818', N'RO075')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1158, N'RV0819', N'RO078')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1159, N'RV0819', N'RO079')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (116, N'RV069', N'RO081')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1160, N'RV0820', N'RO081')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1161, N'RV0820', N'RO082')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1162, N'RV0821', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1163, N'RV0821', N'RO086')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1164, N'RV0822', N'RO089')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1165, N'RV0822', N'RO090')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1166, N'RV0823', N'RO093')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1167, N'RV0823', N'RO094')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1168, N'RV0824', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1169, N'RV0824', N'RO097')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (117, N'RV070', N'RO084')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1170, N'RV0825', N'RO0100')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1171, N'RV0825', N'RO0101')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1172, N'RV0826', N'RO0104')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1173, N'RV0826', N'RO0105')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1174, N'RV0827', N'RO0107')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1175, N'RV0827', N'RO0108')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1176, N'RV0828', N'RO0111')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1177, N'RV0828', N'RO0112')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1178, N'RV0829', N'RO0115')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1179, N'RV0829', N'RO0116')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (118, N'RV070', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1180, N'RV0830', N'RO0118')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1181, N'RV0830', N'RO0119')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1182, N'RV0831', N'RO0122')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1183, N'RV0831', N'RO0123')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1184, N'RV0832', N'RO0126')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1185, N'RV0832', N'RO0127')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1186, N'RV0833', N'RO0130')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1187, N'RV0833', N'RO0131')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1188, N'RV0834', N'RO0133')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1189, N'RV0834', N'RO0134')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (119, N'RV071', N'RO088')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1190, N'RV0835', N'RO0137')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1191, N'RV0835', N'RO0138')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1192, N'RV0836', N'RO0141')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1193, N'RV0836', N'RO0142')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1194, N'RV0837', N'RO0144')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1195, N'RV0837', N'RO0145')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1196, N'RV0838', N'RO0148')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1197, N'RV0838', N'RO0149')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1198, N'RV0839', N'RO0152')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1199, N'RV0839', N'RO0153')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (12, N'RV09', N'RO036')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (120, N'RV071', N'RO089')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1200, N'RV0840', N'RO0155')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1201, N'RV0840', N'RO0156')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1202, N'RV0841', N'RO0159')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1203, N'RV0841', N'RO0160')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1204, N'RV0842', N'RO0163')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1205, N'RV0842', N'RO0164')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1206, N'RV0843', N'RO0167')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1207, N'RV0843', N'RO0168')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1208, N'RV0844', N'RO0170')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1209, N'RV0844', N'RO0171')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (121, N'RV072', N'RO092')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1210, N'RV0845', N'RO0174')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1211, N'RV0845', N'RO0175')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1212, N'RV0846', N'RO0178')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1213, N'RV0846', N'RO0179')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1214, N'RV0847', N'RO0181')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1215, N'RV0847', N'RO0182')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1216, N'RV0848', N'RO0185')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1217, N'RV0848', N'RO0186')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1218, N'RV0849', N'RO0189')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1219, N'RV0849', N'RO0190')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (122, N'RV072', N'RO093')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1220, N'RV0850', N'RO0192')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1221, N'RV0850', N'RO0193')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1222, N'RV0851', N'RO0196')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1223, N'RV0851', N'RO0197')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1224, N'RV0852', N'RO0200')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1225, N'RV0852', N'RO0201')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1226, N'RV0853', N'RO0204')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1227, N'RV0853', N'RO0205')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1228, N'RV0854', N'RO0207')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1229, N'RV0854', N'RO0208')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (123, N'RV073', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1230, N'RV0855', N'RO0211')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1231, N'RV0855', N'RO0212')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1232, N'RV0856', N'RO0215')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1233, N'RV0856', N'RO0216')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1234, N'RV0857', N'RO0218')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1235, N'RV0857', N'RO0219')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1236, N'RV0858', N'RO01')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1237, N'RV0859', N'RO06')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1238, N'RV0859', N'RO07')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1239, N'RV0860', N'RO011')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (124, N'RV073', N'RO097')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1240, N'RV0860', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1241, N'RV0861', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1242, N'RV0861', N'RO018')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1243, N'RV0862', N'RO022')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1244, N'RV0862', N'RO023')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1245, N'RV0863', N'RO028')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1246, N'RV0863', N'RO029')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1247, N'RV0864', N'RO034')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1248, N'RV0864', N'RO035')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1249, N'RV0865', N'RO039')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (125, N'RV074', N'RO0100')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1250, N'RV0865', N'RO040')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1251, N'RV0866', N'RO045')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1252, N'RV0866', N'RO046')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1253, N'RV0867', N'RO050')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1254, N'RV0867', N'RO051')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1255, N'RV0868', N'RO056')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1256, N'RV0868', N'RO057')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1257, N'RV0869', N'RO062')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1258, N'RV0869', N'RO063')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1259, N'RV0870', N'RO067')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (126, N'RV074', N'RO0101')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1260, N'RV0870', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1261, N'RV0871', N'RO073')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1262, N'RV0871', N'RO074')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1263, N'RV0872', N'RO078')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1264, N'RV0872', N'RO079')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1265, N'RV0873', N'RO084')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1266, N'RV0873', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1267, N'RV0874', N'RO090')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1268, N'RV0874', N'RO091')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1269, N'RV0875', N'RO095')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (127, N'RV075', N'RO0104')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1270, N'RV0875', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1271, N'RV0876', N'RO0101')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1272, N'RV0876', N'RO0102')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1273, N'RV0877', N'RO0106')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1274, N'RV0877', N'RO0107')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1275, N'RV0878', N'RO0112')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1276, N'RV0878', N'RO0113')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1277, N'RV0879', N'RO0118')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1278, N'RV0879', N'RO0119')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1279, N'RV0880', N'RO0123')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (128, N'RV075', N'RO0105')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1280, N'RV0880', N'RO0124')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1281, N'RV0881', N'RO0129')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1282, N'RV0881', N'RO0130')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1283, N'RV0882', N'RO0134')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1284, N'RV0882', N'RO0135')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1285, N'RV0883', N'RO0140')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1286, N'RV0883', N'RO0141')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1287, N'RV0884', N'RO0146')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1288, N'RV0884', N'RO0147')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1289, N'RV0885', N'RO0151')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (129, N'RV076', N'RO0108')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1290, N'RV0885', N'RO0152')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1291, N'RV0886', N'RO0157')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1292, N'RV0886', N'RO0158')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1293, N'RV0887', N'RO0219')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1294, N'RV0887', N'RO0163')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1295, N'RV0888', N'RO0168')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1296, N'RV0888', N'RO0169')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1297, N'RV0889', N'RO0174')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1298, N'RV0889', N'RO0175')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1299, N'RV0890', N'RO0179')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (13, N'RV010', N'RO040')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (130, N'RV076', N'RO0109')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1300, N'RV0890', N'RO0203')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1301, N'RV0891', N'RO0215')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1302, N'RV0891', N'RO0186')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1303, N'RV0892', N'RO0190')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1304, N'RV0892', N'RO0205')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1305, N'RV0893', N'RO0194')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1306, N'RV0893', N'RO0195')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1307, N'RV0894', N'RO0201')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1308, N'RV0894', N'RO0203')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1309, N'RV0895', N'RO0210')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (131, N'RV077', N'RO0112')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1310, N'RV0895', N'RO0209')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1311, N'RV0896', N'RO0213')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1312, N'RV0896', N'RO0214')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1313, N'RV0897', N'RO0218')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1314, N'RV0897', N'RO0219')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1315, N'RV0898', N'RO06')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1316, N'RV0898', N'RO07')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1317, N'RV0899', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1318, N'RV0899', N'RO013')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1319, N'RV0900', N'RO018')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (132, N'RV077', N'RO0113')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1320, N'RV0900', N'RO019')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1321, N'RV0901', N'RO024')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1322, N'RV0901', N'RO025')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1323, N'RV0902', N'RO031')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1324, N'RV0902', N'RO032')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1325, N'RV0903', N'RO037')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1326, N'RV0903', N'RO038')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1327, N'RV0904', N'RO043')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1328, N'RV0904', N'RO044')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1329, N'RV0905', N'RO049')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (133, N'RV078', N'RO0116')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1330, N'RV0905', N'RO050')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1331, N'RV0906', N'RO055')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1332, N'RV0906', N'RO056')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1333, N'RV0907', N'RO061')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1334, N'RV0907', N'RO062')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1335, N'RV0908', N'RO067')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1336, N'RV0908', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1337, N'RV0909', N'RO073')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1338, N'RV0909', N'RO074')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1339, N'RV0910', N'RO079')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (134, N'RV078', N'RO0117')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1340, N'RV0910', N'RO080')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1341, N'RV0911', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1342, N'RV0911', N'RO086')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1343, N'RV0912', N'RO092')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1344, N'RV0912', N'RO093')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1345, N'RV0913', N'RO098')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1346, N'RV0913', N'RO099')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1347, N'RV0914', N'RO0104')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1348, N'RV0914', N'RO0105')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1349, N'RV0915', N'RO0110')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (135, N'RV079', N'RO0120')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1350, N'RV0915', N'RO0111')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1351, N'RV0916', N'RO0116')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1352, N'RV0916', N'RO0117')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1353, N'RV0917', N'RO0122')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1354, N'RV0917', N'RO0123')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1355, N'RV0918', N'RO0128')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1356, N'RV0918', N'RO0129')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1357, N'RV0919', N'RO0134')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1358, N'RV0919', N'RO0135')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1359, N'RV0920', N'RO0140')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (136, N'RV079', N'RO0121')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1360, N'RV0920', N'RO0141')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1361, N'RV0921', N'RO0146')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1362, N'RV0921', N'RO0147')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1363, N'RV0922', N'RO0153')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1364, N'RV0922', N'RO0154')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1365, N'RV0923', N'RO0159')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1366, N'RV0923', N'RO0160')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1367, N'RV0924', N'RO0165')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1368, N'RV0924', N'RO0166')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1369, N'RV0925', N'RO0171')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (137, N'RV080', N'RO0124')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1370, N'RV0925', N'RO0172')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1371, N'RV0926', N'RO0177')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1372, N'RV0926', N'RO0178')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1373, N'RV0927', N'RO0183')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1374, N'RV0927', N'RO0184')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1375, N'RV0928', N'RO0189')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1376, N'RV0928', N'RO0190')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1377, N'RV0929', N'RO0197')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1378, N'RV0929', N'RO0196')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1379, N'RV0930', N'RO0201')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (138, N'RV080', N'RO0125')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1380, N'RV0930', N'RO0202')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1381, N'RV0931', N'RO0207')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1382, N'RV0931', N'RO0208')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1383, N'RV0932', N'RO01')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1384, N'RV0932', N'RO02')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1385, N'RV0933', N'RO011')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1386, N'RV0933', N'RO014')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1387, N'RV0934', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1388, N'RV0934', N'RO015')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1389, N'RV0935', N'RO023')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (139, N'RV081', N'RO0128')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1390, N'RV0935', N'RO026')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1391, N'RV0936', N'RO029')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1392, N'RV0936', N'RO030')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1393, N'RV0937', N'RO034')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1394, N'RV0937', N'RO035')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1395, N'RV0938', N'RO040')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1396, N'RV0938', N'RO01')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1397, N'RV0939', N'RO016')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1398, N'RV0939', N'RO047')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1399, N'RV0940', N'RO051')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (14, N'RV010', N'RO041')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (140, N'RV081', N'RO0129')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1400, N'RV0940', N'RO052')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1401, N'RV0941', N'RO057')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1402, N'RV0941', N'RO058')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1403, N'RV0942', N'RO063')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1404, N'RV0942', N'RO064')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1405, N'RV0943', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1406, N'RV0943', N'RO069')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1407, N'RV0944', N'RO074')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1408, N'RV0944', N'RO05')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1409, N'RV0945', N'RO020')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (141, N'RV082', N'RO0132')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1410, N'RV0945', N'RO081')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1411, N'RV0946', N'RO086')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1412, N'RV0946', N'RO087')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1413, N'RV0947', N'RO091')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1414, N'RV0947', N'RO092')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1415, N'RV0948', N'RO097')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1416, N'RV0948', N'RO098')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1417, N'RV0949', N'RO0103')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1418, N'RV0949', N'RO0104')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1419, N'RV0950', N'RO0108')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (142, N'RV082', N'RO0133')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1420, N'RV0950', N'RO0109')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1421, N'RV0951', N'RO0114')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1422, N'RV0951', N'RO0115')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1423, N'RV0952', N'RO0120')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1424, N'RV0952', N'RO0121')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1425, N'RV0953', N'RO0125')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1426, N'RV0953', N'RO0126')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1427, N'RV0954', N'RO0131')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1428, N'RV0954', N'RO0132')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1429, N'RV0955', N'RO0137')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (143, N'RV083', N'RO0136')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1430, N'RV0955', N'RO0138')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1431, N'RV0956', N'RO0143')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1432, N'RV0956', N'RO0144')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1433, N'RV0957', N'RO0148')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1434, N'RV0957', N'RO0149')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1435, N'RV0958', N'RO0154')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1436, N'RV0958', N'RO0155')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1437, N'RV0959', N'RO0160')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1438, N'RV0959', N'RO0161')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1439, N'RV0960', N'RO0165')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (144, N'RV083', N'RO0137')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1440, N'RV0960', N'RO0166')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1441, N'RV0961', N'RO0171')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1442, N'RV0961', N'RO0172')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1443, N'RV0962', N'RO0177')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1444, N'RV0962', N'RO0178')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1445, N'RV0963', N'RO0182')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1446, N'RV0963', N'RO0183')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1447, N'RV0964', N'RO0188')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1448, N'RV0964', N'RO0189')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1449, N'RV0965', N'RO0194')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (145, N'RV084', N'RO0140')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1450, N'RV0965', N'RO0195')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1451, N'RV0966', N'RO0200')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1452, N'RV0966', N'RO0201')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1453, N'RV0967', N'RO0205')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1454, N'RV0967', N'RO0206')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1455, N'RV0968', N'RO0211')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1456, N'RV0968', N'RO0212')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1457, N'RV0969', N'RO0217')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (1458, N'RV0969', N'RO0218')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (146, N'RV084', N'RO0141')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (147, N'RV085', N'RO0143')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (148, N'RV086', N'RO0145')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (149, N'RV087', N'RO0150')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (15, N'RV011', N'RO045')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (150, N'RV088', N'RO0155')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (151, N'RV089', N'RO0160')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (152, N'RV090', N'RO0165')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (153, N'RV091', N'RO0170')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (154, N'RV092', N'RO0175')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (155, N'RV093', N'RO0180')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (156, N'RV094', N'RO0185')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (157, N'RV095', N'RO0190')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (158, N'RV096', N'RO0195')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (159, N'RV097', N'RO0200')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (16, N'RV012', N'RO048')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (160, N'RV098', N'RO0205')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (161, N'RV099', N'RO0210')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (162, N'RV0100', N'RO0215')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (163, N'RV0101', N'RO02')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (164, N'RV0101', N'RO03')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (165, N'RV0102', N'RO05')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (166, N'RV0102', N'RO06')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (167, N'RV0103', N'RO07')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (168, N'RV0103', N'RO08')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (169, N'RV0104', N'RO010')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (17, N'RV012', N'RO049')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (170, N'RV0104', N'RO011')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (171, N'RV0105', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (172, N'RV0105', N'RO013')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (173, N'RV0106', N'RO015')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (174, N'RV0106', N'RO016')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (175, N'RV0107', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (176, N'RV0107', N'RO018')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (177, N'RV0108', N'RO020')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (178, N'RV0108', N'RO021')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (179, N'RV0109', N'RO022')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (18, N'RV013', N'RO052')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (180, N'RV0109', N'RO023')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (181, N'RV0110', N'RO025')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (182, N'RV0110', N'RO026')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (183, N'RV0111', N'RO027')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (184, N'RV0111', N'RO028')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (185, N'RV0112', N'RO030')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (186, N'RV0112', N'RO031')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (187, N'RV0113', N'RO032')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (188, N'RV0113', N'RO033')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (189, N'RV0114', N'RO035')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (19, N'RV013', N'RO053')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (190, N'RV0114', N'RO036')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (191, N'RV0115', N'RO037')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (192, N'RV0115', N'RO038')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (193, N'RV0116', N'RO040')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (194, N'RV0116', N'RO041')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (195, N'RV0117', N'RO042')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (196, N'RV0117', N'RO043')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (197, N'RV0118', N'RO044')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (198, N'RV0118', N'RO045')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (199, N'RV0119', N'RO047')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (2, N'RV01', N'RO05')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (20, N'RV014', N'RO056')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (200, N'RV0119', N'RO048')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (201, N'RV0120', N'RO049')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (202, N'RV0120', N'RO050')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (203, N'RV0121', N'RO052')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (204, N'RV0121', N'RO053')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (205, N'RV0122', N'RO054')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (206, N'RV0122', N'RO055')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (207, N'RV0123', N'RO057')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (208, N'RV0123', N'RO058')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (209, N'RV0124', N'RO059')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (21, N'RV015', N'RO060')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (210, N'RV0124', N'RO060')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (211, N'RV0125', N'RO062')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (212, N'RV0125', N'RO063')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (213, N'RV0126', N'RO064')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (214, N'RV0126', N'RO065')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (215, N'RV0127', N'RO067')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (216, N'RV0127', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (217, N'RV0128', N'RO069')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (218, N'RV0128', N'RO070')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (219, N'RV0129', N'RO072')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (22, N'RV015', N'RO061')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (220, N'RV0129', N'RO073')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (221, N'RV0130', N'RO074')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (222, N'RV0130', N'RO075')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (223, N'RV0131', N'RO077')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (224, N'RV0131', N'RO078')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (225, N'RV0132', N'RO079')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (226, N'RV0132', N'RO080')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (227, N'RV0133', N'RO082')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (228, N'RV0133', N'RO083')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (229, N'RV0134', N'RO084')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (23, N'RV016', N'RO064')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (230, N'RV0134', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (231, N'RV0135', N'RO086')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (232, N'RV0135', N'RO087')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (233, N'RV0136', N'RO089')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (234, N'RV0136', N'RO090')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (235, N'RV0137', N'RO091')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (236, N'RV0137', N'RO092')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (237, N'RV0138', N'RO094')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (238, N'RV0138', N'RO095')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (239, N'RV0139', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (24, N'RV017', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (240, N'RV0139', N'RO097')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (241, N'RV0140', N'RO099')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (242, N'RV0140', N'RO0100')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (243, N'RV0141', N'RO0101')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (244, N'RV0141', N'RO0102')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (245, N'RV0142', N'RO0104')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (246, N'RV0142', N'RO0105')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (247, N'RV0143', N'RO0106')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (248, N'RV0143', N'RO0107')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (249, N'RV0144', N'RO0109')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (25, N'RV018', N'RO072')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (250, N'RV0144', N'RO0110')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (251, N'RV0145', N'RO0111')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (252, N'RV0145', N'RO0112')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (253, N'RV0146', N'RO0114')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (254, N'RV0146', N'RO0115')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (255, N'RV0147', N'RO0116')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (256, N'RV0147', N'RO0117')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (257, N'RV0148', N'RO0119')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (258, N'RV0148', N'RO0120')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (259, N'RV0149', N'RO0121')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (26, N'RV018', N'RO073')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (260, N'RV0149', N'RO0122')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (261, N'RV0150', N'RO0124')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (262, N'RV0150', N'RO0125')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (263, N'RV0151', N'RO0126')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (264, N'RV0151', N'RO0127')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (265, N'RV0152', N'RO0128')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (266, N'RV0152', N'RO0129')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (267, N'RV0153', N'RO0131')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (268, N'RV0153', N'RO0132')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (269, N'RV0154', N'RO0133')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (27, N'RV019', N'RO076')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (270, N'RV0154', N'RO0134')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (271, N'RV0155', N'RO0136')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (272, N'RV0155', N'RO0137')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (273, N'RV0156', N'RO0138')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (274, N'RV0156', N'RO0139')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (275, N'RV0157', N'RO0141')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (276, N'RV0157', N'RO0142')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (277, N'RV0158', N'RO0143')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (278, N'RV0158', N'RO0144')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (279, N'RV0159', N'RO0146')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (28, N'RV019', N'RO077')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (280, N'RV0159', N'RO0147')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (281, N'RV0160', N'RO0148')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (282, N'RV0160', N'RO0149')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (283, N'RV0161', N'RO0151')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (284, N'RV0161', N'RO0152')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (285, N'RV0162', N'RO0153')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (286, N'RV0162', N'RO0154')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (287, N'RV0163', N'RO0156')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (288, N'RV0163', N'RO0157')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (289, N'RV0164', N'RO0158')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (29, N'RV020', N'RO080')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (290, N'RV0164', N'RO0159')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (291, N'RV0165', N'RO0161')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (292, N'RV0165', N'RO0162')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (293, N'RV0166', N'RO0163')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (294, N'RV0166', N'RO0164')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (295, N'RV0167', N'RO0165')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (296, N'RV0167', N'RO0166')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (297, N'RV0168', N'RO0168')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (298, N'RV0168', N'RO0169')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (299, N'RV0169', N'RO0170')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (3, N'RV02', N'RO08')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (30, N'RV021', N'RO084')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (300, N'RV0169', N'RO0171')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (301, N'RV0170', N'RO0173')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (302, N'RV0170', N'RO0174')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (303, N'RV0171', N'RO0175')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (304, N'RV0171', N'RO0176')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (305, N'RV0172', N'RO0178')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (306, N'RV0172', N'RO0179')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (307, N'RV0173', N'RO0180')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (308, N'RV0173', N'RO0181')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (309, N'RV0174', N'RO0183')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (31, N'RV021', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (310, N'RV0174', N'RO0184')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (311, N'RV0175', N'RO0185')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (312, N'RV0175', N'RO0186')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (313, N'RV0176', N'RO0188')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (314, N'RV0176', N'RO0189')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (315, N'RV0177', N'RO0190')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (316, N'RV0177', N'RO0191')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (317, N'RV0178', N'RO0193')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (318, N'RV0178', N'RO0194')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (319, N'RV0179', N'RO0195')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (32, N'RV022', N'RO088')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (320, N'RV0179', N'RO0196')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (321, N'RV0180', N'RO0198')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (322, N'RV0180', N'RO0199')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (323, N'RV0181', N'RO0200')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (324, N'RV0181', N'RO0201')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (325, N'RV0182', N'RO0203')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (326, N'RV0182', N'RO0204')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (327, N'RV0183', N'RO0205')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (328, N'RV0183', N'RO0206')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (329, N'RV0184', N'RO0207')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (33, N'RV022', N'RO089')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (330, N'RV0184', N'RO0208')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (331, N'RV0185', N'RO0210')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (332, N'RV0185', N'RO0211')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (333, N'RV0186', N'RO0212')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (334, N'RV0186', N'RO0213')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (335, N'RV0187', N'RO0215')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (336, N'RV0187', N'RO0216')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (337, N'RV0188', N'RO0217')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (338, N'RV0188', N'RO0218')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (339, N'RV0189', N'RO0220')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (34, N'RV023', N'RO092')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (340, N'RV0189', N'RO0219')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (341, N'RV0190', N'RO03')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (342, N'RV0190', N'RO04')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (343, N'RV0191', N'RO06')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (344, N'RV0191', N'RO07')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (345, N'RV0192', N'RO09')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (346, N'RV0192', N'RO010')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (347, N'RV0193', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (348, N'RV0193', N'RO013')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (349, N'RV0194', N'RO016')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (35, N'RV023', N'RO093')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (350, N'RV0194', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (351, N'RV0195', N'RO019')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (352, N'RV0195', N'RO020')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (353, N'RV0196', N'RO022')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (354, N'RV0196', N'RO023')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (355, N'RV0197', N'RO025')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (356, N'RV0197', N'RO026')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (357, N'RV0198', N'RO028')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (358, N'RV0198', N'RO029')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (359, N'RV0199', N'RO031')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (36, N'RV024', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (360, N'RV0199', N'RO032')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (361, N'RV0200', N'RO034')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (362, N'RV0200', N'RO035')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (363, N'RV0201', N'RO037')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (364, N'RV0201', N'RO038')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (365, N'RV0202', N'RO040')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (366, N'RV0202', N'RO041')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (367, N'RV0203', N'RO043')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (368, N'RV0203', N'RO044')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (369, N'RV0204', N'RO047')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (37, N'RV024', N'RO097')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (370, N'RV0204', N'RO048')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (371, N'RV0205', N'RO050')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (372, N'RV0205', N'RO051')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (373, N'RV0206', N'RO053')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (374, N'RV0206', N'RO054')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (375, N'RV0207', N'RO056')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (376, N'RV0207', N'RO057')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (377, N'RV0208', N'RO059')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (378, N'RV0208', N'RO060')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (379, N'RV0209', N'RO062')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (38, N'RV025', N'RO0100')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (380, N'RV0209', N'RO063')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (381, N'RV0210', N'RO065')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (382, N'RV0210', N'RO066')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (383, N'RV0211', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (384, N'RV0211', N'RO069')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (385, N'RV0212', N'RO071')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (386, N'RV0212', N'RO072')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (387, N'RV0213', N'RO074')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (388, N'RV0213', N'RO075')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (389, N'RV0214', N'RO078')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (39, N'RV025', N'RO0101')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (390, N'RV0214', N'RO079')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (391, N'RV0215', N'RO081')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (392, N'RV0215', N'RO082')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (393, N'RV0216', N'RO084')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (394, N'RV0216', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (395, N'RV0217', N'RO087')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (396, N'RV0217', N'RO088')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (397, N'RV0218', N'RO090')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (398, N'RV0218', N'RO091')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (399, N'RV0219', N'RO093')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (4, N'RV03', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (40, N'RV026', N'RO0104')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (400, N'RV0219', N'RO094')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (401, N'RV0220', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (402, N'RV0220', N'RO097')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (403, N'RV0221', N'RO099')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (404, N'RV0221', N'RO0100')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (405, N'RV0222', N'RO0102')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (406, N'RV0222', N'RO0103')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (407, N'RV0223', N'RO0105')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (408, N'RV0223', N'RO0106')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (409, N'RV0224', N'RO0109')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (41, N'RV027', N'RO0108')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (410, N'RV0224', N'RO0110')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (411, N'RV0225', N'RO0112')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (412, N'RV0225', N'RO0113')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (413, N'RV0226', N'RO0115')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (414, N'RV0226', N'RO0116')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (415, N'RV0227', N'RO0118')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (416, N'RV0227', N'RO0119')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (417, N'RV0228', N'RO0121')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (418, N'RV0228', N'RO0122')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (419, N'RV0229', N'RO0124')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (42, N'RV028', N'RO0112')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (420, N'RV0229', N'RO0125')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (421, N'RV0230', N'RO0127')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (422, N'RV0230', N'RO0128')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (423, N'RV0231', N'RO0130')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (424, N'RV0231', N'RO0131')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (425, N'RV0232', N'RO0133')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (426, N'RV0232', N'RO0134')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (427, N'RV0233', N'RO0136')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (428, N'RV0233', N'RO0137')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (429, N'RV0234', N'RO0140')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (43, N'RV029', N'RO0116')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (430, N'RV0234', N'RO0141')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (431, N'RV0235', N'RO0143')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (432, N'RV0235', N'RO0144')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (433, N'RV0236', N'RO0146')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (434, N'RV0236', N'RO0147')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (435, N'RV0237', N'RO0149')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (436, N'RV0237', N'RO0150')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (437, N'RV0238', N'RO0152')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (438, N'RV0238', N'RO0153')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (439, N'RV0239', N'RO0155')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (44, N'RV030', N'RO0120')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (440, N'RV0239', N'RO0156')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (441, N'RV0240', N'RO0158')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (442, N'RV0240', N'RO0159')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (443, N'RV0241', N'RO0161')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (444, N'RV0241', N'RO0162')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (445, N'RV0242', N'RO0164')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (446, N'RV0242', N'RO0165')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (447, N'RV0243', N'RO0167')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (448, N'RV0243', N'RO0168')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (449, N'RV0244', N'RO0171')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (45, N'RV030', N'RO0121')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (450, N'RV0244', N'RO0172')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (451, N'RV0245', N'RO0174')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (452, N'RV0245', N'RO0175')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (453, N'RV0246', N'RO0177')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (454, N'RV0246', N'RO0178')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (455, N'RV0247', N'RO0180')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (456, N'RV0247', N'RO0181')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (457, N'RV0248', N'RO0183')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (458, N'RV0248', N'RO0184')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (459, N'RV0249', N'RO0186')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (46, N'RV031', N'RO0124')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (460, N'RV0249', N'RO0187')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (461, N'RV0250', N'RO0189')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (462, N'RV0250', N'RO0190')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (463, N'RV0251', N'RO0192')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (464, N'RV0251', N'RO0193')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (465, N'RV0252', N'RO0195')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (466, N'RV0252', N'RO0196')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (467, N'RV0253', N'RO0198')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (468, N'RV0253', N'RO0199')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (469, N'RV0254', N'RO0202')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (47, N'RV032', N'RO0129')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (470, N'RV0254', N'RO0203')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (471, N'RV0255', N'RO0205')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (472, N'RV0255', N'RO0206')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (473, N'RV0256', N'RO0208')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (474, N'RV0256', N'RO0209')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (475, N'RV0257', N'RO0211')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (476, N'RV0257', N'RO0212')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (477, N'RV0258', N'RO0214')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (478, N'RV0258', N'RO0215')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (479, N'RV0259', N'RO0217')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (48, N'RV033', N'RO0132')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (480, N'RV0259', N'RO0218')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (481, N'RV0260', N'RO05')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (482, N'RV0260', N'RO06')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (483, N'RV0261', N'RO011')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (484, N'RV0261', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (485, N'RV0262', N'RO016')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (486, N'RV0262', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (487, N'RV0263', N'RO021')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (488, N'RV0263', N'RO022')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (489, N'RV0264', N'RO027')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (49, N'RV033', N'RO0133')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (490, N'RV0264', N'RO028')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (491, N'RV0265', N'RO032')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (492, N'RV0265', N'RO033')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (493, N'RV0266', N'RO037')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (494, N'RV0266', N'RO038')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (495, N'RV0267', N'RO042')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (496, N'RV0267', N'RO043')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (497, N'RV0268', N'RO048')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (498, N'RV0268', N'RO049')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (499, N'RV0269', N'RO053')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (5, N'RV03', N'RO013')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (50, N'RV034', N'RO0136')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (500, N'RV0269', N'RO054')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (501, N'RV0270', N'RO058')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (502, N'RV0270', N'RO059')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (503, N'RV0271', N'RO064')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (504, N'RV0271', N'RO065')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (505, N'RV0272', N'RO069')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (506, N'RV0272', N'RO070')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (507, N'RV0273', N'RO074')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (508, N'RV0273', N'RO075')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (509, N'RV0274', N'RO080')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (51, N'RV034', N'RO0219')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (510, N'RV0274', N'RO081')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (511, N'RV0275', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (512, N'RV0275', N'RO086')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (513, N'RV0276', N'RO090')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (514, N'RV0276', N'RO091')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (515, N'RV0277', N'RO095')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (516, N'RV0277', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (517, N'RV0278', N'RO0101')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (518, N'RV0278', N'RO0102')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (519, N'RV0279', N'RO0106')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (52, N'RV035', N'RO0140')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (520, N'RV0279', N'RO0107')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (521, N'RV0280', N'RO0111')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (522, N'RV0280', N'RO0112')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (523, N'RV0281', N'RO0117')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (524, N'RV0281', N'RO0118')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (525, N'RV0282', N'RO0122')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (526, N'RV0282', N'RO0123')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (527, N'RV0283', N'RO0127')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (528, N'RV0283', N'RO0128')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (529, N'RV0284', N'RO0133')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (53, N'RV035', N'RO0141')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (530, N'RV0284', N'RO0134')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (531, N'RV0285', N'RO0138')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (532, N'RV0285', N'RO0139')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (533, N'RV0286', N'RO0143')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (534, N'RV0286', N'RO0144')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (535, N'RV0287', N'RO0148')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (536, N'RV0287', N'RO0149')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (537, N'RV0288', N'RO0154')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (538, N'RV0288', N'RO0155')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (539, N'RV0289', N'RO0159')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (54, N'RV036', N'RO0144')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (540, N'RV0289', N'RO0160')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (541, N'RV0290', N'RO0164')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (542, N'RV0290', N'RO0165')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (543, N'RV0291', N'RO0170')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (544, N'RV0291', N'RO0171')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (545, N'RV0292', N'RO0175')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (546, N'RV0292', N'RO0176')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (547, N'RV0293', N'RO0180')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (548, N'RV0293', N'RO0181')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (549, N'RV0294', N'RO0186')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (55, N'RV036', N'RO0145')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (550, N'RV0294', N'RO0187')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (551, N'RV0295', N'RO0191')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (552, N'RV0295', N'RO0192')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (553, N'RV0296', N'RO0196')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (554, N'RV0296', N'RO0197')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (555, N'RV0297', N'RO0201')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (556, N'RV0297', N'RO0202')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (557, N'RV0298', N'RO0207')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (558, N'RV0298', N'RO0208')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (559, N'RV0299', N'RO0212')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (56, N'RV037', N'RO0148')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (560, N'RV0299', N'RO0213')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (561, N'RV0300', N'RO0217')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (562, N'RV0300', N'RO0218')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (563, N'RV0301', N'RO02')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (564, N'RV0301', N'RO03')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (565, N'RV0302', N'RO04')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (566, N'RV0302', N'RO05')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (567, N'RV0303', N'RO06')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (568, N'RV0303', N'RO07')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (569, N'RV0304', N'RO08')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (57, N'RV037', N'RO0149')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (570, N'RV0304', N'RO09')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (571, N'RV0305', N'RO010')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (572, N'RV0306', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (573, N'RV0307', N'RO013')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (574, N'RV0307', N'RO014')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (575, N'RV0308', N'RO015')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (576, N'RV0308', N'RO016')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (577, N'RV0309', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (578, N'RV0309', N'RO018')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (579, N'RV0310', N'RO019')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (58, N'RV038', N'RO0152')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (580, N'RV0310', N'RO020')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (581, N'RV0311', N'RO021')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (582, N'RV0312', N'RO024')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (583, N'RV0313', N'RO025')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (584, N'RV0313', N'RO026')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (585, N'RV0314', N'RO027')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (586, N'RV0314', N'RO028')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (587, N'RV0315', N'RO029')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (588, N'RV0316', N'RO030')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (589, N'RV0316', N'RO031')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (59, N'RV038', N'RO0153')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (590, N'RV0317', N'RO032')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (591, N'RV0318', N'RO034')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (592, N'RV0318', N'RO035')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (593, N'RV0319', N'RO036')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (594, N'RV0319', N'RO037')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (595, N'RV0320', N'RO038')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (596, N'RV0321', N'RO040')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (597, N'RV0321', N'RO041')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (598, N'RV0322', N'RO043')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (599, N'RV0323', N'RO044')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (6, N'RV04', N'RO016')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (60, N'RV039', N'RO0156')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (600, N'RV0324', N'RO046')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (601, N'RV0324', N'RO047')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (602, N'RV0325', N'RO048')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (603, N'RV0326', N'RO049')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (604, N'RV0326', N'RO050')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (605, N'RV0327', N'RO051')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (606, N'RV0328', N'RO053')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (607, N'RV0328', N'RO054')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (608, N'RV0329', N'RO055')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (609, N'RV0329', N'RO056')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (61, N'RV039', N'RO0208')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (610, N'RV0330', N'RO057')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (611, N'RV0330', N'RO058')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (612, N'RV0331', N'RO059')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (613, N'RV0332', N'RO062')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (614, N'RV0333', N'RO063')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (615, N'RV0334', N'RO065')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (616, N'RV0334', N'RO066')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (617, N'RV0335', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (618, N'RV0336', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (619, N'RV0336', N'RO069')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (62, N'RV040', N'RO0160')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (620, N'RV0337', N'RO071')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (621, N'RV0338', N'RO072')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (622, N'RV0338', N'RO073')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (623, N'RV0339', N'RO075')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (624, N'RV0340', N'RO076')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (625, N'RV0341', N'RO078')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (626, N'RV0341', N'RO079')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (627, N'RV0342', N'RO080')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (628, N'RV0342', N'RO081')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (629, N'RV0343', N'RO083')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (63, N'RV040', N'RO0161')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (630, N'RV0344', N'RO084')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (631, N'RV0344', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (632, N'RV0345', N'RO086')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (633, N'RV0345', N'RO087')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (634, N'RV0346', N'RO088')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (635, N'RV0347', N'RO089')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (636, N'RV0348', N'RO092')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (637, N'RV0349', N'RO093')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (638, N'RV0349', N'RO094')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (639, N'RV0350', N'RO095')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (64, N'RV041', N'RO0164')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (640, N'RV0350', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (641, N'RV0351', N'RO097')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (642, N'RV0351', N'RO098')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (643, N'RV0352', N'RO099')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (644, N'RV0353', N'RO0102')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (645, N'RV0354', N'RO0103')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (646, N'RV0355', N'RO0105')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (647, N'RV0355', N'RO0106')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (648, N'RV0356', N'RO0107')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (649, N'RV0357', N'RO0108')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (65, N'RV042', N'RO0169')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (650, N'RV0357', N'RO0109')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (651, N'RV0358', N'RO0110')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (652, N'RV0358', N'RO0111')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (653, N'RV0359', N'RO0112')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (654, N'RV0359', N'RO0113')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (655, N'RV0360', N'RO0115')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (656, N'RV0361', N'RO0116')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (657, N'RV0362', N'RO0119')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (658, N'RV0363', N'RO0120')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (659, N'RV0363', N'RO0121')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (66, N'RV043', N'RO0172')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (660, N'RV0364', N'RO0123')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (661, N'RV0365', N'RO0124')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (662, N'RV0366', N'RO0125')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (663, N'RV0366', N'RO0126')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (664, N'RV0367', N'RO0128')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (665, N'RV0368', N'RO0129')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (666, N'RV0369', N'RO0131')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (667, N'RV0369', N'RO0132')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (668, N'RV0370', N'RO0133')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (669, N'RV0370', N'RO0134')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (67, N'RV043', N'RO0173')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (670, N'RV0371', N'RO0135')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (671, N'RV0371', N'RO0136')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (672, N'RV0372', N'RO0138')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (673, N'RV0373', N'RO0139')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (674, N'RV0373', N'RO0140')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (675, N'RV0374', N'RO0142')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (676, N'RV0375', N'RO0143')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (677, N'RV0375', N'RO0144')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (678, N'RV0376', N'RO0145')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (679, N'RV0377', N'RO0146')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (68, N'RV044', N'RO0177')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (680, N'RV0378', N'RO0148')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (681, N'RV0378', N'RO0149')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (682, N'RV0379', N'RO0150')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (683, N'RV0379', N'RO0151')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (684, N'RV0380', N'RO0152')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (685, N'RV0380', N'RO0153')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (686, N'RV0381', N'RO0154')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (687, N'RV0381', N'RO0155')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (688, N'RV0382', N'RO0156')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (689, N'RV0382', N'RO0157')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (69, N'RV045', N'RO0180')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (690, N'RV0383', N'RO0158')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (691, N'RV0384', N'RO0160')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (692, N'RV0384', N'RO0161')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (693, N'RV0385', N'RO0162')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (694, N'RV0385', N'RO0163')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (695, N'RV0386', N'RO0163')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (696, N'RV0387', N'RO0165')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (697, N'RV0387', N'RO0166')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (698, N'RV0388', N'RO0168')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (699, N'RV0389', N'RO0169')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (7, N'RV04', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (70, N'RV045', N'RO0181')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (700, N'RV0390', N'RO0172')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (701, N'RV0391', N'RO0173')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (702, N'RV0391', N'RO0174')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (703, N'RV0392', N'RO0175')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (704, N'RV0392', N'RO0176')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (705, N'RV0393', N'RO0177')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (706, N'RV0393', N'RO0178')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (707, N'RV0394', N'RO0179')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (708, N'RV0394', N'RO0180')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (709, N'RV0395', N'RO0181')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (71, N'RV046', N'RO0184')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (710, N'RV0395', N'RO0182')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (711, N'RV0396', N'RO0183')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (712, N'RV0397', N'RO0185')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (713, N'RV0398', N'RO0187')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (714, N'RV0399', N'RO0189')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (715, N'RV0400', N'RO0190')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (716, N'RV0401', N'RO0193')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (717, N'RV0402', N'RO0194')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (718, N'RV0403', N'RO0196')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (719, N'RV0404', N'RO0198')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (72, N'RV046', N'RO0215')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (720, N'RV0404', N'RO0199')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (721, N'RV0405', N'RO0200')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (722, N'RV0405', N'RO0201')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (723, N'RV0406', N'RO0202')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (724, N'RV0407', N'RO0204')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (725, N'RV0408', N'RO0205')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (726, N'RV0409', N'RO0208')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (727, N'RV0410', N'RO0209')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (728, N'RV0411', N'RO0212')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (729, N'RV0412', N'RO0213')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (73, N'RV047', N'RO0188')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (730, N'RV0412', N'RO0214')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (731, N'RV0413', N'RO0215')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (732, N'RV0414', N'RO0217')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (733, N'RV0414', N'RO0218')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (734, N'RV0415', N'RO0220')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (735, N'RV0416', N'RO01')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (736, N'RV0417', N'RO02')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (737, N'RV0418', N'RO03')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (738, N'RV0419', N'RO04')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (739, N'RV0420', N'RO06')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (74, N'RV048', N'RO0193')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (740, N'RV0421', N'RO07')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (741, N'RV0422', N'RO08')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (742, N'RV0423', N'RO09')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (743, N'RV0424', N'RO010')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (744, N'RV0425', N'RO011')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (745, N'RV0426', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (746, N'RV0427', N'RO013')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (747, N'RV0428', N'RO014')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (748, N'RV0429', N'RO015')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (749, N'RV0430', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (75, N'RV049', N'RO0196')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (750, N'RV0431', N'RO018')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (751, N'RV0432', N'RO019')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (752, N'RV0433', N'RO020')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (753, N'RV0434', N'RO021')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (754, N'RV0435', N'RO022')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (755, N'RV0436', N'RO023')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (756, N'RV0437', N'RO024')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (757, N'RV0438', N'RO025')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (758, N'RV0439', N'RO026')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (759, N'RV0440', N'RO028')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (76, N'RV049', N'RO0207')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (760, N'RV0441', N'RO029')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (761, N'RV0442', N'RO030')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (762, N'RV0443', N'RO031')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (763, N'RV0444', N'RO032')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (764, N'RV0445', N'RO033')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (765, N'RV0446', N'RO034')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (766, N'RV0447', N'RO035')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (767, N'RV0448', N'RO036')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (768, N'RV0449', N'RO037')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (769, N'RV0450', N'RO039')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (77, N'RV050', N'RO04')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (770, N'RV0451', N'RO040')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (771, N'RV0452', N'RO041')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (772, N'RV0453', N'RO042')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (773, N'RV0454', N'RO043')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (774, N'RV0455', N'RO044')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (775, N'RV0456', N'RO045')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (776, N'RV0457', N'RO046')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (777, N'RV0458', N'RO047')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (778, N'RV0459', N'RO048')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (779, N'RV0460', N'RO050')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (78, N'RV050', N'RO05')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (780, N'RV0461', N'RO051')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (781, N'RV0462', N'RO052')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (782, N'RV0463', N'RO053')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (783, N'RV0464', N'RO054')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (784, N'RV0465', N'RO055')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (785, N'RV0466', N'RO056')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (786, N'RV0467', N'RO057')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (787, N'RV0468', N'RO058')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (788, N'RV0469', N'RO059')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (789, N'RV0470', N'RO061')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (79, N'RV051', N'RO08')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (790, N'RV0471', N'RO062')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (791, N'RV0472', N'RO063')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (792, N'RV0473', N'RO064')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (793, N'RV0474', N'RO065')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (794, N'RV0475', N'RO066')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (795, N'RV0476', N'RO067')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (796, N'RV0477', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (797, N'RV0478', N'RO069')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (798, N'RV0479', N'RO070')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (799, N'RV0480', N'RO072')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (8, N'RV05', N'RO020')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (80, N'RV051', N'RO09')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (800, N'RV0481', N'RO073')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (801, N'RV0482', N'RO074')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (802, N'RV0483', N'RO075')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (803, N'RV0484', N'RO076')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (804, N'RV0485', N'RO077')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (805, N'RV0486', N'RO078')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (806, N'RV0487', N'RO079')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (807, N'RV0488', N'RO080')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (808, N'RV0489', N'RO081')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (809, N'RV0490', N'RO083')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (81, N'RV052', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (810, N'RV0491', N'RO084')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (811, N'RV0492', N'RO085')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (812, N'RV0493', N'RO086')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (813, N'RV0494', N'RO087')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (814, N'RV0495', N'RO088')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (815, N'RV0496', N'RO089')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (816, N'RV0497', N'RO090')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (817, N'RV0498', N'RO091')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (818, N'RV0499', N'RO092')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (819, N'RV0500', N'RO094')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (82, N'RV052', N'RO013')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (820, N'RV0501', N'RO095')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (821, N'RV0502', N'RO096')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (822, N'RV0503', N'RO097')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (823, N'RV0504', N'RO098')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (824, N'RV0505', N'RO099')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (825, N'RV0506', N'RO0100')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (826, N'RV0507', N'RO0101')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (827, N'RV0508', N'RO0102')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (828, N'RV0509', N'RO0103')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (829, N'RV0510', N'RO0105')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (83, N'RV053', N'RO016')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (830, N'RV0511', N'RO0106')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (831, N'RV0512', N'RO0107')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (832, N'RV0513', N'RO0108')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (833, N'RV0514', N'RO0109')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (834, N'RV0515', N'RO0110')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (835, N'RV0516', N'RO0111')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (836, N'RV0517', N'RO0112')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (837, N'RV0518', N'RO0113')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (838, N'RV0519', N'RO0114')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (839, N'RV0520', N'RO0116')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (84, N'RV053', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (840, N'RV0521', N'RO0117')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (841, N'RV0522', N'RO0118')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (842, N'RV0523', N'RO0119')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (843, N'RV0524', N'RO0120')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (844, N'RV0525', N'RO0121')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (845, N'RV0526', N'RO0122')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (846, N'RV0527', N'RO0123')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (847, N'RV0528', N'RO0124')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (848, N'RV0529', N'RO0125')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (849, N'RV0530', N'RO0127')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (85, N'RV054', N'RO020')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (850, N'RV0531', N'RO0128')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (851, N'RV0532', N'RO0129')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (852, N'RV0533', N'RO0130')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (853, N'RV0534', N'RO0131')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (854, N'RV0535', N'RO0132')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (855, N'RV0536', N'RO0133')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (856, N'RV0537', N'RO0134')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (857, N'RV0538', N'RO0135')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (858, N'RV0539', N'RO0136')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (859, N'RV0540', N'RO0138')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (86, N'RV054', N'RO021')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (860, N'RV0541', N'RO0139')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (861, N'RV0542', N'RO0140')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (862, N'RV0543', N'RO0141')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (863, N'RV0544', N'RO0142')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (864, N'RV0545', N'RO0143')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (865, N'RV0546', N'RO0144')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (866, N'RV0547', N'RO0145')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (867, N'RV0548', N'RO0146')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (868, N'RV0549', N'RO0147')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (869, N'RV0550', N'RO0149')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (87, N'RV055', N'RO024')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (870, N'RV0551', N'RO0150')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (871, N'RV0552', N'RO0151')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (872, N'RV0553', N'RO0152')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (873, N'RV0554', N'RO0153')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (874, N'RV0555', N'RO0154')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (875, N'RV0556', N'RO0155')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (876, N'RV0557', N'RO0156')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (877, N'RV0558', N'RO0157')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (878, N'RV0559', N'RO0158')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (879, N'RV0560', N'RO0160')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (88, N'RV055', N'RO025')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (880, N'RV0561', N'RO0161')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (881, N'RV0562', N'RO0162')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (882, N'RV0563', N'RO0163')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (883, N'RV0564', N'RO0164')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (884, N'RV0565', N'RO0165')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (885, N'RV0566', N'RO0166')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (886, N'RV0567', N'RO0167')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (887, N'RV0568', N'RO0168')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (888, N'RV0569', N'RO0169')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (889, N'RV0570', N'RO0171')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (89, N'RV056', N'RO028')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (890, N'RV0571', N'RO0172')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (891, N'RV0572', N'RO0173')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (892, N'RV0573', N'RO0174')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (893, N'RV0574', N'RO0175')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (894, N'RV0575', N'RO0176')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (895, N'RV0576', N'RO0177')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (896, N'RV0577', N'RO0178')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (897, N'RV0578', N'RO0179')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (898, N'RV0579', N'RO0180')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (899, N'RV0580', N'RO0182')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (9, N'RV06', N'RO025')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (90, N'RV056', N'RO029')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (900, N'RV0581', N'RO0183')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (901, N'RV0582', N'RO0184')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (902, N'RV0583', N'RO0185')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (903, N'RV0584', N'RO0186')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (904, N'RV0585', N'RO0187')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (905, N'RV0586', N'RO0188')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (906, N'RV0587', N'RO0189')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (907, N'RV0588', N'RO0190')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (908, N'RV0589', N'RO0191')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (909, N'RV0590', N'RO0193')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (91, N'RV057', N'RO032')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (910, N'RV0591', N'RO0194')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (911, N'RV0592', N'RO0195')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (912, N'RV0593', N'RO0196')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (913, N'RV0594', N'RO0197')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (914, N'RV0595', N'RO0198')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (915, N'RV0596', N'RO0199')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (916, N'RV0597', N'RO0200')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (917, N'RV0598', N'RO0201')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (918, N'RV0599', N'RO0202')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (919, N'RV0600', N'RO0204')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (92, N'RV057', N'RO033')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (920, N'RV0601', N'RO0205')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (921, N'RV0602', N'RO0206')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (922, N'RV0603', N'RO0207')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (923, N'RV0604', N'RO0208')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (924, N'RV0605', N'RO0209')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (925, N'RV0606', N'RO0210')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (926, N'RV0607', N'RO0211')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (927, N'RV0608', N'RO0212')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (928, N'RV0609', N'RO0213')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (929, N'RV0610', N'RO0215')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (93, N'RV058', N'RO036')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (930, N'RV0611', N'RO0216')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (931, N'RV0612', N'RO0217')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (932, N'RV0613', N'RO0218')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (933, N'RV0614', N'RO0219')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (934, N'RV0615', N'RO01')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (935, N'RV0616', N'RO02')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (936, N'RV0617', N'RO04')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (937, N'RV0618', N'RO05')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (938, N'RV0619', N'RO06')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (939, N'RV0620', N'RO07')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (94, N'RV058', N'RO037')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (940, N'RV0621', N'RO08')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (941, N'RV0622', N'RO09')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (942, N'RV0623', N'RO011')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (943, N'RV0624', N'RO012')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (944, N'RV0625', N'RO013')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (945, N'RV0626', N'RO014')
GO
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (946, N'RV0627', N'RO015')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (947, N'RV0628', N'RO017')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (948, N'RV0629', N'RO018')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (949, N'RV0630', N'RO019')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (95, N'RV059', N'RO040')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (950, N'RV0631', N'RO020')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (951, N'RV0632', N'RO021')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (952, N'RV0633', N'RO022')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (953, N'RV0634', N'RO024')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (954, N'RV0635', N'RO025')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (955, N'RV0636', N'RO026')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (956, N'RV0637', N'RO027')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (957, N'RV0638', N'RO028')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (958, N'RV0639', N'RO030')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (959, N'RV0640', N'RO031')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (96, N'RV059', N'RO041')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (960, N'RV0641', N'RO032')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (961, N'RV0642', N'RO033')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (962, N'RV0643', N'RO034')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (963, N'RV0644', N'RO035')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (964, N'RV0645', N'RO037')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (965, N'RV0646', N'RO038')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (966, N'RV0647', N'RO039')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (967, N'RV0648', N'RO040')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (968, N'RV0649', N'RO041')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (969, N'RV0650', N'RO042')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (97, N'RV060', N'RO044')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (970, N'RV0651', N'RO044')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (971, N'RV0652', N'RO045')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (972, N'RV0653', N'RO046')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (973, N'RV0654', N'RO047')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (974, N'RV0655', N'RO048')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (975, N'RV0656', N'RO050')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (976, N'RV0657', N'RO051')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (977, N'RV0658', N'RO052')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (978, N'RV0659', N'RO053')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (979, N'RV0660', N'RO054')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (98, N'RV060', N'RO045')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (980, N'RV0661', N'RO055')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (981, N'RV0662', N'RO057')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (982, N'RV0663', N'RO058')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (983, N'RV0664', N'RO059')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (984, N'RV0665', N'RO060')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (985, N'RV0666', N'RO061')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (986, N'RV0667', N'RO063')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (987, N'RV0668', N'RO064')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (988, N'RV0669', N'RO065')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (989, N'RV0670', N'RO066')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (99, N'RV061', N'RO048')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (990, N'RV0671', N'RO067')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (991, N'RV0672', N'RO068')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (992, N'RV0673', N'RO070')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (993, N'RV0674', N'RO071')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (994, N'RV0675', N'RO072')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (995, N'RV0676', N'RO073')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (996, N'RV0677', N'RO074')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (997, N'RV0678', N'RO076')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (998, N'RV0679', N'RO077')
INSERT [dbo].[RoomReserved] ([ID], [ReservationID], [RoomId]) VALUES (999, N'RV0680', N'RO078')
SET IDENTITY_INSERT [dbo].[RoomReserved] OFF
GO
SET IDENTITY_INSERT [dbo].[RoomType] ON 

INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (1, N'Standard Room')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (10, N'Honeymoon Suite')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (11, N'Adjoining Rooms')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (12, N'Accessible Room')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (13, N'Penthouse Suite')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (14, N'Chalet')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (15, N'Bungalow')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (16, N'Villa')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (2, N'Deluxe Room')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (3, N'Executive Suite')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (4, N'Junior Suite')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (5, N'Family Room')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (6, N'Presidential Suite')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (7, N'Pool View Room')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (8, N'Garden View Room')
INSERT [dbo].[RoomType] ([ID], [RoomTypeName]) VALUES (9, N'Poolside Room')
SET IDENTITY_INSERT [dbo].[RoomType] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (1, N'James', N'Smith', N'james.smith@example.com', N'5556667777', N'123 Oak Avenue', 0, N'¼TwP¹''—ùU³aÌ›Ý\Ý÷Ð†!QÐ:zÚ‰•ª$©­$a6¦‹À-¢AAîQg
êídi	šDSó5Ë#µÚ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (10, N'Logan', N'Taylor', N'logan.taylor@example.com', N'6665554444', N'123 Pine Road', 0, N',åö5Ò[y7©,™ð¯mð*húi[tù…çÙ>Óõ¦qQhTT´ÂþìŸÓŸÌM÷Oï’á,©mÀ>û¢æ£')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (100, N'Alexander', N'Leone', N'alexander.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'1l?Çì9ET¿s«X?%f¿óH å(Ë¦÷¦#¼ÌÁŽÌË‘1¿P_™nþ(Ã+£`Èu(rÔòµÔ´IVö`Ô')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (101, N'Liam', N'Romano', N'liam.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'ö®¯–Ótp‚¦Ž8üÕQöã;êúè5—‹r²;¨<x-öÊJ¨ºÆQÌÂ¼5Þ__žÚ£Å3Z\‡¢W')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (102, N'Charlotte', N'Ricci', N'charlotte.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'¹ˆî‹X|_›­%Äáá°óF‰¹ê<^a÷[z;÷%e”×ƒÕ›îî•M° ß¨<$Â7ìí‚~³Öô1fÃ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (103, N'Ethan', N'Sorrentino', N'ethan.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'ƒ,ôøe—2ÿÂ{ˆ;Ø)¢+ÅIàPzt T‡$häH‰f»Ý§¾†º”G¤…-µ ÚNEýñÖ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (104, N'Olivia', N'De Angelis', N'olivia.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'Ëaýðò´˜ˆ¨‚Œî"Íaî€7oï’IQÄ’jŽ»ÿ‹ÄO–wãgsæväájg‘‡´îì¥„±OÚ\é')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (105, N'Aiden', N'Marini', N'aiden.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'aNhº_Pùd`"C–jÖ!";l Ïj{i·ýõ–[a–îJ=NÏ áÆ4ì[µ+ª^Ú.jñu¬2ÑÇ?ç®Ÿ	')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (106, N'Mia', N'Lombardi', N'mia.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'’þ¾RŠý‚I¾øYø9Nç‰°ìD)GêˆÍ0h³;ÿ¨×Âƒ•táïÞš*_ècíRp½åygäÃ	îÇ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (107, N'Lucas', N'De Rosa', N'lucas.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'S‹¯ïHE°"^)]YY¤èùij85Îø3J7q£¿Kqõ­O´û+1ÊfO–Í§@ä”Nf²Ý¦ë³kø—ƒÃƒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (108, N'Isabella', N'Russo', N'isabella.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'‹r©}sw HÌj0Zã¼?JsT+d[d‘Œ¾În	Ð3<æÓó«Úè•"ö&OµXÌ?˜Ï2G§%êT2KOžŠ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (109, N'James', N'Ferrante', N'james.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'çž¡eþ?¬­ÁA=áÞÿ,›ÿp1G	»£»ò.¿''ïPõ%wrégvÈžgq$"Ÿã•9ÜŒ@õ	ïÿÒ&{')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (11, N'Sophia', N'Anderson', N'sophia.anderson@example.com', N'5554443333', N'456 Cedar Street', 0, N'òr½ã ]+êÏð…*ð“UÈå—zÇ”ú‰ÑiÄaöµÖîýk„pÃläõ¡Ï-ù<ªÜµ\æþß€<')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (110, N'Amelia', N'DAmico', N'amelia.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'Á¾ü†g"L
K1@¾®¨Ê\LÓ˜¾
6nšÇyXe“¥Ä(¡âù%llp{÷ßŒÃB1À`;Ô
')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (111, N'Henry', N'Battaglia', N'henry.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'®ï*€¼qŽ˜fl¼(Âˆ?úYÕ¸jáÅÓ1Œ^ºâÛ$''óvÐx9;D1nes08¨aøèôjîêØþ‘')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (112, N'Elizabeth', N'Rinaldi', N'elizabeth.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'·Óøµ:Íu/¨è¤2ëùâŽ«C£¦»1Xo»:c…C9"çGÀƒÿ€Nè¦‡á‘bLmŽ1´Ï ß3¸}!aÌZ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (113, N'Alexander', N'Guerra', N'alexander.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'æ-öÏñºg xi
žÝëºr®Ja«ADíTáÜŸ4Åíç¾B8«@ÜgÔ.­êäôýRâÎßV¼ú½þ»
')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (114, N'Samantha', N'Marini', N'samantha.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'ÝGO-$Úe»x¸r{ØqWwžÔL—å¾ ãÚ
$Çkî´¼ëkÖ[©«^Ag8ÕºÝó}N9°%&nóÝm')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (115, N'Daniel', N'Caruso', N'daniel.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'¹Å§§4^eÉ¾IãÃA;ñ¨2L¡¡R·ìŒ-2º~c™MM
®5¦öÇÕV~v58Å?àuDöL')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (116, N'Scarlett', N'Barone', N'scarlett.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'÷â‰»éš›&¥«¤¿„#û¤áñ)I“í
QopåÄ=¼íöáÏj›Þ¢©œ¡Þ…ë¡pG/¤+©¤Ü')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (117, N'Joseph', N'Valentini', N'joseph.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'Éÿ‹¦;:ÙvÚÎžú’êyŽ<†î×à®ÌE»ä9^¤yÛÅ’ËQF—óåæî~¨V£Ë?¤]Q.9m:"O¯')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (118, N'Emily', N'Battaglia', N'emily.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'|šêÂkuœ½`ÍQX:5Íç5Ûòqu­úÝ
•¿»G‡•ù=éão·W†âBºÕ?fÅ@;öîÿÉÆÈTD')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (119, N'Benjamin', N'Bianchi', N'benjamin.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'E±N‰YO®uõØpâ˜Œ³ûž¤;÷s,,¯–¼kÆ»«AüËtBÊHaHí¾0šÉŒ¦IúeÍE,4]õ7ð˜û')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (12, N'Jackson', N'Thomas', N'jackson.thomas@example.com', N'2223334444', N'789 Elm Street', 0, N'U-ÂæÃQá¦ÿªÛ2Û¬º®ëƒY©öì3fŽ’e™|Š¨ú‹PgY¹‰t+ð´åfìòŸ“YÓ"NÎñÎBÄì­')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (120, N'Evelyn', N'Leone', N'evelyn.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'Åá4ðùë˜hwN&Wº}”ÞËÖÀýTÕ’Î/“Ó_#ëž¬Ÿ¼`ù*
J^-J è}ð9,¦Ô’Ðqq')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (121, N'Sebastian', N'Romano', N'sebastian.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'Ós¼Nš=Rþâ}V^“êHÉUY	$Lg0JLA:Œ=ëø®1²;É1Vh cñÆ”œlVNJƒ¡yˆ£!Pm')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (122, N'Avery', N'Ricci', N'avery.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'¹9ê5¨ÝœªõiØq÷”çÚc—jB…Y3ù[ZF¦Ç•qŽå—|&V»ÚÂ…y6''.+ê§V,~¼…Ú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (123, N'Matthew', N'Sorrentino', N'matthew.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'¾Ôï¡Ôý½•KÓp]j*x''É¥.Ï¿°Æb¯\v¯aÿëïjÊõÐ+7ª…O«Ò¶œy
çNìþÃËjÄ¿')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (124, N'Harper', N'De Angelis', N'harper.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'ZÏ`ÞÒ@`bñRYÔu érÚû¿…éù
¬tñümugÏH˜ì	ÒÞ/ýÂ
@a-ý;Qƒùˆ2šòð')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (125, N'David', N'Marini', N'david.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'O_’ˆ1HŠÖÀ¦äK×‹ÈRåæÑ{õÍËÍ¦ªô¹æ»jƒÌ‚‰¤¯$¼8ŸÛWyQ iiLðF''»Týÿ&YS')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (126, N'Victoria', N'Lombardi', N'victoria.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'’Ü¼Ài+duÂ~Ë^`‚Ïüßtfµš¸a¬¢€þ¸û
îU’¢=˜›
dý¡$}–Ì°3Ì«?¯þÌñ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (127, N'Joseph', N'De Rosa', N'joseph.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'e3Y0b£‘:eÉ ÆxGY¯3TCr+~‚@NœeºÞ8§uËœlÑf‹Ñ 	¹™¡³ÚQûÏ"p
Ô	U(')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (128, N'Aria', N'Russo', N'aria.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'Cyò)´úwÀºuç
}
‚¢Ýiz§Ä}ŸÏÂÒäì2vÛ¼C-Yo‘Ø»nÆÛQ^8*îÁ4ø*àyŸ‹ìÅ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (129, N'Samuel', N'Ferrante', N'samuel.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ÆLÿ gtÞ1à•OU»ëÀª)Ý3i×E­HÅ×ZJh&•6yÄÆ[qÜm_êÇ¨]11¥rÿ‘Aê66˜azgw')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (13, N'Olivia', N'Jackson', N'olivia.jackson@example.com', N'4443332222', N'321 Oak Avenue', 0, N'4Ê2›ƒ¿+ÃÏÕn-ßÆç4º«tJ‡úåšÚ>QÙ§Q^™w ô.P—©´v¾H5øå™ããÜå!¤û')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (130, N'Grace', N'DAmico', N'grace.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'‡èA×’yÅ03HÚ·žTDM24£YãºÊATha°ÿ Ó1¥Ž¼H8Rm‚Ò`
6ÈD²^H7:±¥')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (131, N'Jack', N'Battaglia', N'jack.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'¸ßAVÇg˜þr7-·L@ó„‹S¡&Ã÷†`³q‚£9ŸäMíÝÞÁå/Ì¤.6ÎœºÅÕûÆ…CÆ—´?¾')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (132, N'Sophia', N'Rinaldi', N'sophia.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'68›Q¶$³…ŒkÖ}Üªëâ¨ÖžôAîd]$2¾µ‘f''¦?ÿ}çÐ©N¤M*PO%Š×‡¥€
‡”&‡')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (133, N'Owen', N'Guerra', N'owen.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'ÖÏk€î¶¬g~†ò`VÉ¨[t”îk=	Ý¶I2ž“íAèAÉÇ°Ë‚ßez›![ÆÃ^ÜšÈ@D#')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (134, N'Abigail', N'Marini', N'abigail.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'(ÛÓV	Ü.m,ŠÃÉn<ôf¹ã“Ù¢6ð%,âSäPÎÆÎÉ‰£jÃ’ÒghžÍŠHKô†ãuFLóù¶ý')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (135, N'Logan', N'Caruso', N'logan.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'dðû±a¸‡9=ÔÜZWôxÇ	''dòl>K%24ØéK¨¨¾e°R®zíÀ7b€þ¬¿Á ˜°áþÊŸ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (136, N'Avery', N'Barone', N'avery.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'O÷¿(zù™4á± UøÕ—hÇmq”ÈDêf`¡lâ™3\‚ÚÍµHñ«qd
f¤è--fâ¦ôŽüÖ{Å5T×ç')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (137, N'Emma', N'Valentini', N'emma.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'M+úwÍÂ¯’Àq!áøü*™„óƒÑ~ÜisÊÉÃŒ.äÆ;„³Í«±O ¬³7¼¨8ÓÂepz²àêQÊœÐØ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (138, N'Carter', N'Battaglia', N'carter.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'eO7W´Dem?åúÈó¹ËºíyS"RDsô43á«¡ô Á PÔ«"èÖÍª"Ž¹Ùß;…,ÓBºßÍÌ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (139, N'Madison', N'Bianchi', N'madison.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'I½}?œ*i=q`£‹6h£QVTËü ORÇÒC²ÅŠ— ?×°²<$Ôªþ4LÄLãíùCÙ7¤%Y­Ù¦')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (14, N'Aiden', N'White', N'aiden.white@example.com', N'5556667777', N'654 Maple Lane', 0, N'lƒãÂ¸ 5¿UÇtôÙáP¿¢’¶Tˆ>‹ ©.óYN?xTãpM÷€yÛ³phÉž&!ù4„–ÏsFÜ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (140, N'Henry', N'Leone', N'henry.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'¿''ø"óYKeÃ
÷Y>õ¶s°ë}‡RÁ›ÌêŒâîþè.[<Ð!>$fdaM%í“óGÖH+ŒÛ|Óª¹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (141, N'Jackson', N'Romano', N'jackson.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'â		¢zb.JpÛ+›ñ¸D%(WÒ*Aº’úO•!œ¤øŽ„ð`O§OI¥¶
ÎÔ\c"ºÓë6Ë^2O½ ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (142, N'Layla', N'Ricci', N'layla.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'—|ÐÐ}Z´‡Þ/É+÷?œæµÉ„X\GÃå±úMbŽ¸qc6˜5Š[
šz^†rîÝ«1qU6¬LÔ³')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (143, N'Michael', N'Sorrentino', N'michael.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'oÑƒI‘œÓSP¤óJŠÇTx>U·Ïi›h… ÆÍeCñ¹°úsß½³ê4¨P–S,¹RÍµº‰OÌ¹hÇÎc‰')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (144, N'Chloe', N'De Angelis', N'chloe.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'«®öhsË&Nù6!£%Ï-§ÛÒÜ6¦Ò»Èše¬Så®ô÷HhÍÒ PÕÝ-VÊf»Z—:Æ[0ý"ómÑ½t¼Û')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (145, N'John', N'Marini', N'john.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'¢Ä^¤{²6/ß]‡Àa3Áü–±ÙÔ ==µ¡
ïXÒ­W=½¿‰(ÌÄ
)n‹Vþ(¤ÞË¶(%õ`ŸÄÊ/')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (146, N'Penelope', N'Lombardi', N'penelope.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'}9Þ²•''
Þ(Å 8ÃKàã^ØËA‹ÀÌi^æsÚžÎ·¦j½³1
Â"Äˆ¡ç«‰}''j‰üF,·™Ç\')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (147, N'Daniel', N'De Rosa', N'daniel.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'NÊ@+Noäf¼?¯¯’BXîg°OwóÞ‘&6˜Ö©$&
üâ¤Gê!EbS?hï:ÉëeVŠ(ª_kfhŽ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (148, N'Zoe', N'Russo', N'zoe.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'”«ªÎyA›áŠ|Ê«d"rüu+/Pù³·ÍLXêE¦BkG†ãm”dãØ¬îXÿI«Nþ
Ê(<•`g5')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (149, N'Elijah', N'Ferrante', N'elijah.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'¹l
CÖÚ›Ï¹«ùÑéÏÃ¶Ã™‹ñå²§ûGêgªÞLîJªnÖÒVdš¾jð0ó¸¤V¤Ï={™æ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (15, N'Mia', N'Harris', N'mia.harris@example.com', N'1112223333', N'987 Elm Street', 0, N'VDíTc®·xõ¤]%­0ÝH0ì^y¬‚®''wåYgu•‰G¡`y8Ò-<!û‡mÆœ“EÜìÎ
ùKÆ·')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (150, N'Lily', N'DAmico', N'lily.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'y¯á¥{›duÂÛÎ¶&J¤ZVÒ\ÝE’}@²Ì‡±]ÕÉn•kZÔ“toã
%‡¥Ñ-Ñ§Ì#kG½ƒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (151, N'Gabriel', N'Battaglia', N'gabriel.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'ÕÌdN`=†CÁYëÏ™>ZS‘¤LmÏÊA=¯ÑÙ&—žö,Á_65 <°Æ ¥AvŒQ¯I˜#~U|')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (152, N'Sofia', N'Rinaldi', N'sofia.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'Gé‹„Î*2šýÃÃû~ŸpáÖk%ý€¾ ­Ù¿yUÛ}µp¦`í›õ„k‰#K÷næf¡”ë ñŸwað˜^')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (153, N'Caleb', N'Guerra', N'caleb.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'óÌèó´ü­?‘¨™8Ž6ˆ]x| Êw°‘jYÆØ8v å''kB1PðŒ•Û‡ÝxÎˆS(¬½%ÉÅÛèZµÎS')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (154, N'Alyssa', N'Marini', N'alyssa.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'Ê{ÆªÏÖrˆºá³ÔLOxµÏ“±`ÞS5ís~2±‡<ûÈ–ÙGŸ{]ŠÖ÷¬%1ú(¢‰Îÿïl:l3')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (155, N'Ryan', N'Caruso', N'ryan.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'BÕF½ØGŠc[4f|jrwÖ5snÖ¦7ùóhÆ-OYçŸöõ
VïÞ‰j¸’ÌJ¤ßª•Õ§üEçÍûäRQ‚')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (156, N'Leah', N'Barone', N'leah.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'R©êqÕõ±7¢Íd÷ÇŒ¿±Ç’nÓÖšÃ:¨õ—›ß‰j‡Jè‘\PC? x=läh''u<éÙbùÉ	?Ý')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (157, N'Nathan', N'Valentini', N'nathan.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'Î¦5û*´©M“2JñF‚"˜)ÑošÔzkFþØ3EXŠñyh€-¥ðt}ßrv‘ÒŠ@bv¤òøRä‘m€‘')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (158, N'Audrey', N'Battaglia', N'audrey.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'dvÈÆ«6¬ÝlÍ×_ÇÚL@áø •Ž¬KŠJÖÉ¹K°üÁ]¦Ñê™nVýï‰%™+ç¨¦ýÝ‡£¥¼^')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (159, N'Anthony', N'Bianchi', N'anthony.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'ƒÆ!‰/·v…q¸ìˆ¢§rœ]eìàãÖÁ€¤"XQ(ð FY6Ïîƒ¡èœ(…_õ2=¤¦³íølŸ<ZhÝz')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (16, N'Lucas', N'Clark', N'lucas.clark@example.com', N'4445556666', N'234 Pine Road', 0, N'37‹{fÅï¨4
/‘&9 Å4‹þg³H‡l‡FeÓ2ÇpÔêRIlWNÙëÜëhpµ¾©6mÁt¼
|\')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (160, N'Hannah', N'Leone', N'hannah.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'¨ü¬ZŽ}Ží[7Ì ›6Òë	¨BÔ«55yÕ©Áç†ˆyøjõ—¤šã
´+|¦Ò¥ˆGÝ8CÙ›9¬')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (161, N'Isaac', N'Romano', N'isaac.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'÷€Œ«.K2ŽÏi]’ÐžO­BãºÉEõì—reY.lïÚbaçµ×]ãJ8œºh"ÿDWc‚dÇ[ç')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (162, N'Arianna', N'Ricci', N'arianna.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'§[Žo_ irù…fPÙð¾Ô{ÉîƒÓŸ4L:™óMOÊ¿D¾lyGr>ÂÇ¦q¸ã­:ÊõJMp5êÌûZ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (163, N'Andrew', N'Sorrentino', N'andrew.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'TÈ¡Àzº<d±H7§ú^‡VgCw¢åà%6½#0#8ûâNØï^ÈT«ÊÄÏEqwû¨öþH½¢¬7¾k¾>')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (164, N'Mila', N'De Angelis', N'mila.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'— Õ''y½:&U}E‡“tn½ÒûÚK®ñã5FWòÿ\9V÷ß~ëæºØùäÀ[Ž¹*92UïD–a')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (165, N'Julian', N'Marini', N'julian.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'Ñ6cO[ý§F¸W3Í¿åÇpa''Å¦‘3b×ÓõH	uR…šOÑ—Ž
 B®Gtyu•¢;º±·¹$C(™+| )')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (166, N'Nora', N'Lombardi', N'nora.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'¢µ3,@±²»ÌŒ§	ª KˆXüä•ûdÒ¬ÜZ­
n°¿Fâ˜
Ób„˜ñL©uñ¹¼l‡´''RÜÝ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (167, N'Jonathan', N'De Rosa', N'jonathan.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'ì^9ãîqåGzú`ø*Y¦”Ý03”0×ãnFÍÚˆÆX|”#Ö”¦‘­seŠæQ
~¦¹È;­™ß.Ô±')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (168, N'Camila', N'Russo', N'camila.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'Vd£ìÖÄÓ‰á  ¤Çöá¢àeÈT’[Z•X ètàm¨ ‡é&h}ì<º•a67ÊªÔ]ùÛ¡Onn‚')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (169, N'Josiah', N'Ferrante', N'josiah.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ÜJFÔg
Ì¾w,‘µ–«/»ÝÃ­úÞ€-ü;½†:­Þ;—u¡Ã¡‡»Å/~’XØ''KE6E<)ë7YÔ2F­ü')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (17, N'Layla', N'Lewis', N'layla.lewis@example.com', N'6665554444', N'567 Oak Avenue', 0, N';ËV‘àTGÈ%®aÆ.öm]³dxFéWã3ÂÏ1Kœlt
(‹çŽÿA4%t¾ï]oõ‡ÓŽÌ:>³')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (170, N'Addison', N'DAmico', N'addison.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'ÖÀ.J®wÈ!®€•EWèiû:*Ù¼J_®ÍÊmæC-¼ºòOWd±Q?C%xöXš×ç¾ö€')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (171, N'Charles', N'Battaglia', N'charles.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'âÚY}U™w	yÒ¹óÖ	*K]q]	ŸX°xèðžÂyÊÓ"Ã~‘/Üª*’S+
}šºÜéçïŠ,¼Ç”-{u')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (172, N'Scarlett', N'Rinaldi', N'scarlett.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'ó¼UVd¢ƒzCËìäÑf“ÌrÖî™h¨Ø ''×RyN˜š¡¾œÏ^ˆ	œÃW{~Méø©øFjðBiß	ŠEÈ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (173, N'Jeremiah', N'Guerra', N'jeremiah.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'ßrÕ©alÐ°i‘zÙ''hyn®~  :¸nd–]ìj1\7¶Oxiø#ç§¢•¿N#B\0C˜“ÜZqŸ‘°')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (174, N'Hazel', N'Marini', N'hazel.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'ÅSöúNÞ’ì}Í|Îò¸u£·üDIÇNá<4…™²ÚT}Jò3Þ“Ê18PÁ£×Ê=vÐÞÎNá÷
Õ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (175, N'Josiah', N'Caruso', N'josiah.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'QÿZžäŽeëL¶jïÏº5D°6”Þq²Ô9Œ’^±šW/†Æpe:—Ï’3•Åõ+Æ"_ž´ÒmN.P6òQ²')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (176, N'Grace', N'Barone', N'grace.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'j×~SÛeSÑT*Q6lÝuƒÑ2ÆÌm—%!ÝSGÑ
oüåC°ªÅz}ØŽ+w•$“õFz?Û–')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (177, N'Eli', N'Valentini', N'eli.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'‰yŠ''°
ßXè\ŽtÈ©º¬ò
Ô~ÿ‹gp&
¶M6QÖd$&Ì`PÁ…ùÒá·€è¬ƒ‘•ÜÞ±ý€p')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (178, N'Aubrey', N'Battaglia', N'aubrey.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'-÷f
?¥†æA84òFŠü&¶yg¹
Ó7s¨b5(Ì,¯´Á°iKuBD@©»…ÉuÆÈ·qÊ =xñ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (179, N'Thomas', N'Bianchi', N'thomas.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'“J=‚:OÝøÀ+ü•Çü®yQ41Ž?´ÈÛa›@×X.SøÛ€J•ˆÁS0Î—’Sb@z¼³Ú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (18, N'Liam', N'Lee', N'liam.lee@example.com', N'5556667777', N'890 Cedar Street', 0, N'bëEFâþ$ ,ÜöÈÓÔZJ°7·âß/œS\¢à‚ÇÛÕŠ‘ÿÐÎHAHb«IÑãrà6ã@8¹úi³°É*û')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (180, N'Aaliyah', N'Leone', N'aaliyah.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'üÕuð´úó‡13¡Jfá6¼»oä9²ýa²=PM‘ÄÕO-å·÷«¢R1§«þ/ÿ5Ü¿kŠH0^')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (181, N'Levi', N'Romano', N'levi.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'\ÞÎß<WVªê
9.Tðž³4uê^u<‘ˆ ýmæž3Q¶lN¾×êt„ÀÿÜ”Òµ>/3p')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (182, N'Victoria', N'Ricci', N'victoria.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'v(\üæ ÊËA÷^OW]óPPö†²üçq½÷è¨2]<)p éÃœé2s²ý“VO>ž‚SÕB«×kr7˜')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (183, N'Nathan', N'Sorrentino', N'nathan.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'c ³ñºÚJ1§ÑðÂ§ä,Û:7ß‹­o¾LŸ=•þÁø0„1v7ö	[¥)ÚA¹àÏ“™LÀzð Jœ\Cì%R')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (184, N'Aurora', N'De Angelis', N'aurora.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'}„>á§Õ1Ú°9eÇ›¬In	Ù¬u}[U“ò	zö½nïŠÏ_P Ô ×üdmu&¨`¬É hO_Ã=,¢û2')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (185, N'Christopher', N'Marini', N'christopher.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'çç^óë9+^¹—à‰ðçE®%=Åó¶kÖ¿iÿ%×ÝxÊxf«)VŠÅd9
”‡ÄÝ*&ÆŸ¶œ•CS')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (186, N'Ella', N'Lombardi', N'ella.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'ßrÊèmD#
å6ZEo¢øÖûÄ¾óõ¢êbkã›ùïßs(§õÄÀ_×¢ÚÉ[1¦OU›P¸hí&3³0ûÔC')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (187, N'Adrian', N'De Rosa', N'adrian.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'ŠþâQ$bÜÙU?âÔhñKç^XD5÷hÇ‰DÔø:|R[KÁ,’†î­Å*R$®ŽÁ fÂ5ºñ''')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (188, N'Brooklyn', N'Russo', N'brooklyn.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'2¦À<Á“@³îœ«¼Z&lƒ"¡¸UM°£â''‘"øVµ…ÍßU‰	fòyA3>W"œ#ßÝ˜®úà®³’3K./')
GO
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (189, N'Jonathan', N'Ferrante', N'jonathan.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ÇÏÑGøÒ·YÖ*þüü’ÍdÃt×¯Óf&Òœy`sˆ‚~d„Á•`x)ÌõhB+îž‹ãÀ’o3	uÌ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (19, N'Harper', N'Hall', N'harper.hall@example.com', N'7778889999', N'123 Pine Road', 0, N'9B"žpk5ñ„ä›}vàc’Îš{éw—}k›p©æË"Üô¯êÈìýUº¼Ù¯=ÁÌ Á?*;dòìRÍ$ˆ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (190, N'Ellie', N'DAmico', N'ellie.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'êRè}¹k Ñ¢‹7ÈÓU:Ô¨ä}EêÖ¼-¯êKXâV¬È¯¶â’¨™è)²û•‰d½Î£¼Ë¯OK&/YK')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (191, N'Aaron', N'Battaglia', N'aaron.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'-n>…•x‚,áV6c_åéåÅ^lóî=3o¨ˆ•wàQ`#húø}Êvc¼¹¤†''œ¢=ØÍ«Ÿ-')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (192, N'Maya', N'Rinaldi', N'maya.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'!Ì¥É›LÅ]»ïEÓpDKÛHº@Ž¼µ-ù¬Û)ÀéœYý²Œ5c²÷t/þ¥Qaoî†*Šå°næìY')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (193, N'Hunter', N'Guerra', N'hunter.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'õpo39í	v#xqýa¾-‰>§Æ¢IÀ=nRÍ‚0j9Èœ¾1CÔ»þ~)jn*ÛæÔÒu­Ñ“#u[™–„Þh')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (194, N'Mila', N'Marini', N'mila.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'§ÇÉ®Äâ''³¤Àûœ®®XÓÎÊqóx`o”*{‰CÉå@LE:qO†þ.ãlªÄoÞ¨tq°ÅZ.nŠ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (195, N'Elias', N'Caruso', N'elias.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'öî5Ðü-pá±™!äa™‹ãi5fÌ¢tÞ’ÓÖ?Ü0ñ0®Âönœb&|°;¹Ãa{¶†‰÷«ä5\+')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (196, N'Stella', N'Barone', N'stella.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'SFö	¿+\•õ¶©‡˜_½P?6 .¯Þ„yïªé‘Ge;:eX—è¨A¬ËPK¬°cY¸åz•Ø,<ì^z/éƒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (197, N'Jeremiah', N'Valentini', N'jeremiah.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'n7i:ÊIÂcr~6Ÿ=>ñ)	ðô3Gfæ!ØIÝ„Ð\¢=Èñºì\9ig3­úJÉ³½7Ç‚´|á:JªL')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (198, N'Gabriella', N'Battaglia', N'gabriella.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ÌWˆUPœ\žÆbM|‰Ûc¦øeqVÀvV+söjÆ]²mØdù o¹ÊÌ®¢¨˜6
p»téuÑ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (199, N'Christopher', N'Bianchi', N'christopher.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'lÇ“Oã–Ùúo6/g0q7ZÏƒ@ËÎí/À¯/yð¼º-|&ÆæÍRO7hgp½GªÉLõ½A
ƒû l/ÛÔ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (2, N'Emma', N'Johnson', N'emma.johnson@example.com', N'4445556666', N'456 Pine Road', 0, N'’¨‘øˆç.‹‚f<7ÌmaFlPŽÆ+2XŠþ5G²·T)ª ª:·ÏÌXƒlsC´>ý6€€¢%1¿6?')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (20, N'Elijah', N'Young', N'elijah.young@example.com', N'5554443333', N'456 Cedar Street', 0, N'™4Lî¼˜á:a†›Õú ~p…›æÈLríy{>×§w
!éåÛeQ2¬Ð›ÿs† –K§<ŒO•eÕ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (200, N'Lucy', N'Leone', N'lucy.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'×èµj­ˆ†·P§oI‡’23.™.Áæ ¥¡e`
ââ
–îÒ³<íð€Ê?jÀü‚~âÙ¦›î¨·EÜÕÿœe')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (201, N'Asher', N'Romano', N'asher.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'aþØ¹Ë _°àè)|LkË:¯ÊB­QxÔ×½èÐ“i";1IÙ¾W_/ RS(Ï­
''k„Š.ºN ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (202, N'Nova', N'Ricci', N'nova.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'´¸cÁ»m)îÀ_bÕ‚Qéô¾§øZÙåô|.Ð#W^ºxtìpB¨¶ÒrLjÈ©uX½—Ú<ŠÛPâŒHiXüé')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (203, N'Jeremiah', N'Sorrentino', N'jeremiah.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'÷¸š¶{Ah×ëYH]V2âò•ŸCÃöÝÞ¦5ð…"HÿBÖdÏ
¨"S`2óBNªá-V]’$´$u')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (204, N'Luna', N'De Angelis', N'luna.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'ò,4zÌ\K¿Cè•{HhDÜ‡L´c9~“+z¾N­´§Y=MS|û«Š€-<¢Ô@)›lâµŠ4àûY-³Ä')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (205, N'Mateo', N'Marini', N'mateo.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'P·*sô
X´F³U±•\¥[èyöáþ±ýLØCüWªí|¢ôe,úˆ5b–v/×¦§•)E5Š’ó')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (206, N'Aria', N'Lombardi', N'aria.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'ž|ÓµXPÁëdü@Û>êaí''‹ro¬I³Â¢_êxªÚlÿJ‹.ˆ£Ž’ÚïºÝ”!ÃWXõŒ,?<¸úÕ%»Ã.')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (207, N'Adam', N'De Rosa', N'adam.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'e)2b¦£	ºrÍ¡ñc•%"Ø4‰€½ò_=ÆòvnXc•Ùøo£Ä“ª
ò©hç»¹X¸Nú!¥ ô')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (208, N'Hannah', N'Russo', N'hannah.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'’[1Ú³¦€y>Ë‹nL/]?.¬€Eéne,Üåî¬Ðl»[+Ê*äÃØî jUµz»¡f6‚vQ=úõó
4q')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (209, N'Julian', N'Ferrante', N'julian.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'¤qfvÅÕl·"™Éˆd±¼u—0ñsUw-£â''ÉžF/“Û`<kû÷‚C4ƒ¤ž‘P(}e—Æ÷[$')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (21, N'Avery', N'King', N'avery.king@example.com', N'2223334444', N'789 Elm Street', 0, N'Èõ¯7ÿgOG
À
îèk	¸;½ (òðgž¢1!tÌ›õž–)+{<1’Ž“SÒ©ŒšØÞ›Ví§B,0')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (210, N'Zoe', N'DAmico', N'zoe.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'òLËzì}y„jhÊÖ1ì]oÙBœ¿”
¾Â—È«Ó¦Ì§Š©Ñ‡•ùã—,%˜S ª»	Û¤Ïù»‚')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (211, N'Elijah', N'Battaglia', N'elijah.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'Ñ‹¹r‹|[f™0‰‹£û¥^uò«O¹}ÃÈÇ=s™Ý5 vˆcRÙ
ºx)»Zõ®Š£‰ÑºÀàÞ²m')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (212, N'Lily', N'Rinaldi', N'lily.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'¿á~½¾µ…Ì!ª<ûÔß(Ì©Èk<Û†‡ŒXÈ˜;û£>B…ù!¦ßàªÞÕÉåg%0”Ú_á¹u‰ñ?U†”')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (213, N'Sebastian', N'Guerra', N'sebastian.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'1­”Z§Zßá•¤NHBµÀ¦ÂÏ‰[,Åp`
Xµ8V{9üÙ7õæŸÜÛmgQ;ðe	TA–6D ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (214, N'Grace', N'Marini', N'grace.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'`Ä
Ù@À‡J½0r~Ã,|8ˆÓ>ÅeO†žŒ#ŽÙâzôçæHÜ¢r\üT ™W§oû4ý©oi|‡W§')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (215, N'Eli', N'Caruso', N'eli.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'†‰Hh’}Ä—©®ö7«sè¬Á½‰¯ât {ƒ„¤TØaIv1¿¹äÝgk©æM»Å¸Ý%Ž0Q?°')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (216, N'Mia', N'Barone', N'mia.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'¾LæëDð9»9œ¦Ž†ü•f§Ä''d]¯™™¤n™üåVÐRAézjœ7ï^§ðàã%ÆSœÎÌL')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (217, N'Joseph', N'Valentini', N'joseph.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'áx‰*ïÿORç^Ãù:ál‰Þ“×Ð>(1B
ÇÝ€5Qþêœ—|–äµÊHC´5Váìæ]S¬ŸO.')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (218, N'Eleanor', N'Battaglia', N'eleanor.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'Ñù;Ò<sËZÈ–¼C&ãïV‘Mb}‰–³=‹6ó «}ªÀ0‘"…y³Ó*9¦+¿^@_EØ0iÏ	ÐMÆ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (219, N'David', N'Bianchi', N'david.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'›i9aÐïpiï™­„2fB?á~hSpíýì;›~àçuå›hð‰L˜S›¡,º*ùGøÝÁó6P2¸ŒQ»')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (22, N'Scarlett', N'Baker', N'scarlett.baker@example.com', N'4443332222', N'321 Oak Avenue', 0, N'º9‰~¨zHYKösdŒ‚ÐQ«ä½¹‡Á¶Bò²ÍôÐ¯´?åHD=Lù
,›ÅÓä=®‰”$–nKC''5”«¨öÂ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (220, N'Mila', N'Leone', N'mila.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'ºšžå¨™kCÛìÞÔ^ ¦<±ROì»ÁÀÇÍ ^Ó—ýîà£îîOþã´[è}€ì²¹ÜPÉrýkcá\ª4')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (221, N'Caleb', N'Romano', N'caleb.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'ùË¤mt«³6ëÛnJ‹&QÕ1€­PÔŒYÝß@<¼±ºŽ(d[ÅK9~oÆlÍZÈ½ˆö××ÑãË‰Ái0')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (222, N'Amelia', N'Ricci', N'amelia.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'"õT!àcéé86Ã•ÓnÝÊëtÂ
Ú 7ù,òarH‚Âˆ{uf>/ñR‡óžš‰}¨ìýýõ¤t')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (223, N'Daniel', N'Sorrentino', N'daniel.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'f¿Žºêù‰ ¬ÝÛš:ŠòK|Ê–Ô¢ªs‰Á^[d®¼ª¾RmÆ·*PÉ¤Œ´+{
ìºÀ4ÕPbœìÓ;')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (224, N'Sophia', N'De Angelis', N'sophia.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'ä3ÕÚ(-e:%%¹cÔžß6xF³æjÌ~,kî#‡k×nÂ-êdÏO0C|i7 H¡­„l6„æ0¤hg“[SŸõ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (225, N'Michael', N'Marini', N'michael.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'j£ úwlÕÜœª7Ô{}~²7$Î“å#ëóOîšá^á2kPY+!Õ›Ç!ò!#ñ›p©Êôë	XÈŸË‘Á')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (226, N'Avery', N'Lombardi', N'avery.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'bõpsnQÝƒ@	Ý ¶¸,UÄìsH3Jºamu”¬ÊÈ(c–ýÚL
9GSô/Ñk"ÿ*6|ÈýÓf,f§kž«')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (227, N'Scarlett', N'De Rosa', N'scarlett.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'ªÎÓ›s@`PR«0³orÆÄpIP±:¥''É€ÿ?}¬fó‡Áp:òG½zk9”.žJ£¯w(Bæ?Ú­')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (228, N'Henry', N'Russo', N'henry.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'y–Ã$|ô Ä@§žpSTq7&r®yd^Q•ûAvÊkÅú)…éÔŽâ$=.]# ½j°HãIM8=sUQŽ@L')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (229, N'Violet', N'Ferrante', N'violet.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ÀD `cºê©!´€Ðfc„VäKÕ—ï#1N¤ü§ëyC{¤×ö‰^#˜åà¡ÆN:^ªD
qÉsm+]7fÓvÖÞ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (23, N'Sofia', N'Gonzalez', N'sofia.gonzalez@example.com', N'5556667777', N'654 Maple Lane', 0, N'¶EsÙ•bP_œ†Á)«¯ÉyÒ°c=ÑæûlH_2´¶¥Ö ¿÷ÉU`ƒëbÊ%™nƒû¥¹¤8—üKk')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (230, N'Ethan', N'DAmico', N'ethan.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'
S`_;EwÂ˜®vh?éAmÅ?ý°U •©æ Cy‰v„NÂk•6ÌêqßÊéÅv·u)L|ñ;>¹Sµ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (231, N'Abigail', N'Battaglia', N'abigail.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'¸<D~3øFdßÝÆÍS€ûM5Pp¢XUØw
=`8IÖzY5Š •>gÀKµm¯SpöyJBèT	¬à„XÓ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (232, N'Charlotte', N'Rinaldi', N'charlotte.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'qÝ0:…¼O¿SŒ‘æ–º!)±ÎON3$*B "[p§hx-QŽ·}Õ†u@ùýø_%ËRcªj |(>•ïD•')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (233, N'Benjamin', N'Guerra', N'benjamin.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'Îyµà
Šï>>Ã~Í,ËºH04Àååq‚g) Kê¼”×63~…jür¦]Ár[	\¬®tñÑ:K•/Ó¯')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (234, N'Elizabeth', N'Marini', N'elizabeth.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'b²adúMgDaôèMóßÏðš3WöÀYà¨¸É¨’Îi™¶iøÈ¨/ÈÄá‹þïicUÔ
À&zó…ÿÈdZ‡.')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (235, N'Sofia', N'Caruso', N'sofia.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'ó"ƒÏeøhûC“¿€¥¬¶WK.«#6_µÎ«µ0`¾¼Ã’ó°¡!È0ÝÍY¥^_šGžeˆCZz—ç¡ÒÅÛú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (236, N'Daniel', N'Barone', N'daniel.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'³=&OQ/3¿6Ö“–›Ub/(ËVnq¥{#BëØˆvuJ
Rž¼B-U%R%ç3¢J%Ã¡€Èžƒ…Z˜a40')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (237, N'Mason', N'Valentini', N'mason.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'½©¸ß“I’¾´?Ñ¦''>
UÅYÌh§L®6zðQ2lëþUweâ×‡]L²’Q1*cz ›ø|È´Éž‹T<ùÜë')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (238, N'Emily', N'Battaglia', N'emily.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ƒÚìZSÀË#Ò[û4''º¿LÌßŒ¥’7úñÖK¾/Øí™ß1qeLjµlnß4}vU£pÝ>è¹E')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (239, N'Jackson', N'Bianchi', N'jackson.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'ß‡mW{zà¥O:"s5ƒÉDNÓÄ‡òÑ}xàÊ¯£*’å@Ì{£ÀàÅ#¬ùíÍšLœ‹H@5±«Ï¤†ðià')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (24, N'Henry', N'Nelson', N'henry.nelson@example.com', N'1112223333', N'987 Elm Street', 0, N'Â«IfOC
(qX¿YQ-ï	}š×&cªð²¨%—%HÐÂ1¶¼å¼‡‰]£,KLIJ¤7¿¡çÑ“ €”†')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (240, N'Evelyn', N'Leone', N'evelyn.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'¤EÛ¥ÈJ¢[rÀ»3Ef¼awíRÝ…Í¡]T›Ö,ýÐ6óJ+¬[ x¡/gÍ§Ííye©µÉ
¦ÔÏi')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (241, N'Oliver', N'Romano', N'oliver.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'ÇAQ63dÓñ·Ê/OV‚ÜCW{¿YP^F\ji¾Q½&x](ÍäÏI©¸-!ƒ;6&~O®öôÉ;­e')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (242, N'Ava', N'Ricci', N'ava.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N' ZJùM–Ý~Ê3hº8ñšg*Ã(`”MÜµ²Ÿ‰á•ü[èöYæ3•_)‹‰¥	r>s›ó¡ÇäÉ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (243, N'William', N'Sorrentino', N'william.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'{-—³‘Y|jÏq£¾6­MÀPlQîkµ·ûßæ#èv_	‹))Kä@/<¢Œ/æ ßþù~zÕñ`')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (244, N'Harper', N'De Angelis', N'harper.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'G2åÝ4*lÝ¹	IrãÔÚÔ†}žQéDî}9toa×ˆØŒ½¢(þ1F««Ðh.ç¥`Ô4ZejìÚ×6
')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (245, N'James', N'Marini', N'james.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'ÌÌö°º•Ã:…:@K *d}[v¡¼*ÝG»¯*n\xh¬™¨ÛÔ^è–³÷ßëw¶t7xÕð£æM­eXñÀ¹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (246, N'Mila', N'Lombardi', N'mila.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'[òzI¯:Þåž-=ÂTñzˆR!}¸*4d½	Çchr…kA2Å©›:4ç_¦^rÞìOìXKy.]ÆZ$ó³k')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (247, N'Sebastian', N'De Rosa', N'sebastian.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'¯>ÿÕ./u<÷ñ˜ò§/Í·ö6ž÷
N5Þ¾©½ŽO<{¸åÂ>JÄqú¤''r¹mí*huÊ´c{ŸäC')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (248, N'Evelyn', N'Russo', N'evelyn.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'ØÞâïä8]R©1èl”×!ôŽ _-~IíKÍSÈÎ¼WW¿Á­‰EŸ	x¥ti*‘Žd\—Ç×‚ËRá›–œ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (249, N'Michael', N'Ferrante', N'michael.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'$.9·|}Rq`&†Œ®=/Ójg·x©wSŠàöà;ktÂ9@¹Z“C™ÝYÉ½š%Ø?“$‡sÝÃŒéb8¹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (25, N'Mila', N'Carter', N'mila.carter@example.com', N'4445556666', N'234 Pine Road', 0, N'Ô…-Éyþ	KYæ}5…nØ#~äz¦Õu«ÅS<…„íhGß›”€°„gâLëq«
šXÜð¶ˆ¥G')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (250, N'Emma', N'DAmico', N'emma.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'''îÉV¹ö¦fŸÜ­Xvl*Ó“¬PðŠá>³<€Ó¿fÔ¿s;Ð¹ŽŒo“‰_ò»Ê5Ks¿w^›÷öú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (251, N'Jacob', N'Battaglia', N'jacob.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'þfc±B6ÔÓæîÎyÅó—ä„€ w¹˜Ì÷åÄóxÛ†\:
ÖpÚ.jlÍ"ˆñ_éD5')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (252, N'Ella', N'Rinaldi', N'ella.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'Z­öo*—Wb> æÅ{è§.Á¼H¢kt988`8]¥µ¿ÉÁ1QA†•-L>óFG ìmƒÂ×ídöhŠðÊ¶')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (253, N'Alexander', N'Guerra', N'alexander.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'W‘rn£Â²‘Þ+ó„ÈY—¢Ð(9¦ˆzàðÂL|š˜ü66½¨Ù¾¡Ø¼¦ãÎ¼d;4\‘ÈÉU†¿âþlR')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (254, N'Liam', N'Marini', N'liam.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'±{./-e‰Øe½G÷W¹<¢î>¦gÍF ·kÔð^º:ndTtfæV5=Kð*Ú‡Î_­Åè~{%ô')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (255, N'Mia', N'Caruso', N'mia.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'Žœª
-NºúQeÔYä¡ÄºDÐ/öS2$ö“’®¡Ž’ê•„x3¹Ú™÷Ë}RnpÿÝÝù¢Â{àü¾¹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (256, N'Emily', N'Barone', N'emily.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'AíØ‡.+ÎbF
ýáîK‡Ù¼ô¹Ræ
–‡J,
ç)ÆÙ€²tàoYkhÃ[™&·Û­…æé›³V%€…,i')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (257, N'Samuel', N'Valentini', N'samuel.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'ÀV''–)þ"ÐÀÜÂ£ßëó†›±½F»†—±ÃŸ´œ8Íœq:U,sG
H#pˆžýÄÍ®TÒ0–Ë ¶luàà')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (258, N'Victoria', N'Battaglia', N'victoria.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'Eñf¨Œž"îTª—ð2Œ·8—Xœ|¡''ÄÑû<Þ&L{K!E;È4ÖE=g3N|«tõÔÎÀÌÿIá›q')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (259, N'Daniel', N'Bianchi', N'daniel.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'ˆ˜H9.é,X†ã@óg½ïò~)«gz€R²mNW“ùÜ%hŽ” Búdç@óo-ÿïm4Öo¥G*‘Êx1K±')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (26, N'Sebastian', N'Garcia', N'sebastian.garcia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'AÆìá(¸«k6)]žÀÇêË¶œ‡…GøƒbqKâ-¦™XÇá²¿Íá¤!e:Úr¼9»¶ëÍ±~3:Pím«')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (260, N'Aria', N'Leone', N'aria.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'¦iiÇu;!³³2h½-©­i<Ì¦¤/Ýmzòï1òÌ.ã	›„¥¢…j:ýMÒsá&<>)yîSÔ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (261, N'Jackson', N'Romano', N'jackson.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'šÈ0×æõ_Îm@ê‰V— XîÓÅÀ_ˆ1ÿwÆÝ„u„3‘Ý’ß“ü¾ùìÄÜ¥™p\½ø=é¹Ú«Ö¸‰')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (262, N'Luna', N'Ricci', N'luna.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'¿Äôü[À»ñàž2«Ê*%Pê ^ó;–
c??¨‰ñVé@Gžt’€yùjÆb»9ØuŠ¾Ï)ËÂ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (263, N'Benjamin', N'Sorrentino', N'benjamin.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'LDvöæUAµÁ^dÇKb—0hlm$£ÆbzSQ¬&­À¾dnîÜÍÎÞ
}Z´ü+''J… ˆ"ÎrÖ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (264, N'Lily', N'De Angelis', N'lily.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'
LUXâûã/v¶óYD»ù}Fk6
‹N<s÷½´&õì‡¦ì_IÄÞÞ2çßPB5DÂíux„¹LÙ©')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (265, N'William', N'Marini', N'william.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'¯îE†u·}€¡ÈK“=ùê¯ì_î"¤kÃ9Æ;î©[IËŒ‘‡ÀÏ~!EŠ2`Í^ÝOÈ¾ƒê­ùoŒ%‹¬X')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (266, N'Elijah', N'Lombardi', N'elijah.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'X¦6”U˜ØÌ…7ÌÔùs‘p¢…¿¸IUÈ>ûö²Ñ²ÐþM‘€1˜‚
ÀÈkJ¶Å?Hh%›©‡¯óä³àï')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (267, N'Avery', N'De Rosa', N'avery.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'<c<HÓwÄá‹ê*û¶j+O:Ÿ79F\Qî¾x2“sjúé
™YCöµúòÐÇm×€l!À‚a1nÜÛfËÐ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (268, N'Ella', N'Russo', N'ella.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'MªúfaG|ºs~ù[³Ðç yß¹G×/Ëç»v0æY¥§JÙMSˆ÷Ï´Õ·¢05Eõ^GÄ—')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (269, N'Oliver', N'Ferrante', N'oliver.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'p×ŠNOý3°ÂŸiÝc©Í ?Ú[z/Jž þgýš*''Ü¬õ ''>––3”Ž¦>€þóÂvxî°Ñ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (27, N'Leah', N'Foster', N'leah.foster@example.com', N'5556667777', N'890 Cedar Street', 0, N'LŠ^ÔýÔDÕ[oØ]2y¬ Ç3±!ŸÿH&Sîý¸üÛWQ†+rq@½FIÿ°–YR$ÚÜ>Âïúš')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (270, N'Charlotte', N'DAmico', N'charlotte.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'píPi„œÞ''å0”ñ½>t¶¶ÏÀ¡çœ¦_ô%Y0	Ç„fÄ¹„/§zu–Ì».‡ËÄÓKˆzÁa_g')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (271, N'Lucas', N'Battaglia', N'lucas.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'1ÔRDy©N6š^’¥×—5ÃH°<&Ð¼"÷tÿ¦NƒÉ7þ;£†Ãå¦D¨e¾ÐzsÅ¹ä+k^W s˜†À?{')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (272, N'Sophia', N'Rinaldi', N'sophia.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'	+?\%¯5ãó:ìù ¢Ô
žÃ)œÔ¹[²PqÓ=Å…	jd	tÕ
yÜ³uý£–ÎÊsÉ‡âá:ætŒ‰')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (273, N'Henry', N'Guerra', N'henry.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'–nÇŒ™Á-ó$³Ø¢&R-¤LgXM{z9üI¨ Ky4ãégh$!;ŠÜªMc.ÓhP]
Ïêä¡b')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (274, N'Daniel', N'Marini', N'daniel.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'9™(¦¢¨ûs`‰àfû(ôÿ"€
%I =¢]8?ï2?Ž%ßàP†Øæ½²]ªg$fÎ7Ë{L´êÓRÜ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (275, N'Harper', N'Caruso', N'harper.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'[”ªWîTFïcž$vC—>+Š’jR¢ïÆÖ•æ’²jË|¬äcM]_þ¸‰»?“Õ[È¹Â/Ä1¢')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (276, N'Ava', N'Barone', N'ava.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'†ØÉRR_ÌÄ‚,>ÙHá8ÝãÜÔnB½Üë&@óã_Æ;d•–Qð×TWZÐŠ–}FfdÞSYQ/ÐdS')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (277, N'Ethan', N'Valentini', N'ethan.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'Y>÷!¬žåØ]f>±ßb”bîkç)ÝƒD{Åª“¨÷n“t:Ç>Üú¤ÉKþÂêÁ€´§sŽêÙïõ/_à')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (278, N'Isabella', N'Battaglia', N'isabella.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'0ãm±ÅÒ€D¤.éûÝ®o´WR¼ô¿š_·ÌÏ]O±d«¨¢ÉN<þ!" F¼¡àn¾I{¼äî¨Òvk¦üÁ')
GO
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (279, N'Mason', N'Bianchi', N'mason.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'×WÌ”ëpmÜ©Ôßù]^¶·ªô §Ž•´­gý±œ~Øvû0nå¢g-ÎþK$›lÝ"c„»×è9OC€£')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (28, N'Carter', N'Hill', N'carter.hill@example.com', N'7778889999', N'123 Pine Road', 0, N'?&vÇm¿õ÷¶-‹ûpènh=¶Øš<Ê2·H¾DwÚPÁ
°žP&Z~"…»l²EÏŸ5…‹Üã‹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (280, N'Liam', N'Leone', N'liam.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'ôå˜h
½uÐ,µëý§@ôºçÿqŽñ|=#|$®¥ù‚—/ë•x{G¬2Ú.@$€†=Æbè—;ƒÐ3‹lÍ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (281, N'Olivia', N'Romano', N'olivia.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'æ?®uê³ÃÄ#ÄTƒßd|«Çb%èOäÔ	‰Ò\ì:Õ»öÇÛÂ½Ù,:‡×3r…''¼¤#èn5¹þÏjÊG”o')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (282, N'Emma', N'Ricci', N'emma.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'…ýüÐ„Y}éŒí¸¸*ÄkIµóíÆ$ˆíˆ›Pe³™ÕR]–øW`
g+X¹Ä=÷lbuø•ßŠLŸKÛç')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (283, N'Aiden', N'Sorrentino', N'aiden.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'§op4²|ˆ‰Ü·/Ÿ×Øü¯¤˜Ç³¹ß²=
Áñ2#;¼È(ŒþCq''µšØžÓ7Åx—¦L±Ü¨ÉÂÝR¹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (284, N'Noah', N'De Angelis', N'noah.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'ÙW‡z“c/þüØëAHPöfSH$g€É5oÄA÷å5ç=Ï+c i$Í©QDcÒ|*J×G·E<÷hö–ñ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (285, N'Aria', N'Marini', N'aria.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'¶ÔßS
?Êa dY cŸ5,—"¹Sìçzû$ü×yhI²FŠT[(‹bêúåkìé*$FO7|6I»')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (286, N'Sophia', N'Lombardi', N'sophia.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'ðªæÆÐI·†¾šðŠÚq÷µÆPEAº³ô©×š7ÄâÔÎ:âé)q‚|¦¬lÍÐžsþÙ[íç')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (287, N'Jackson', N'De Rosa', N'jackson.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'º&çÙ2J­uº…|µ-+Ff¶î<''IM¶OEÉ<ºúðÛØ:Çqcƒ)èA¿r ±©†d…¸¬rø>ö')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (288, N'Evelyn', N'Russo', N'evelyn.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'm5_÷W.º§ž&ÝÒ¬VÏ]Ë·£˜3½ûBùªå³%d†oÿ>àw^Ýšãô›ESÖçà1£ƒÍ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (289, N'Michael', N'Ferrante', N'michael.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'Ø›Äm†žÄ¦ Ý¸Kî¸ËãœÏµ7`Øþ­.lž»ñ¤}³Ž
ícx`È`Õ¼o2M¨F»—×²±XðÍ¡¹ýP')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (29, N'Elizabeth', N'Adams', N'elizabeth.adams@example.com', N'5554443333', N'456 Cedar Street', 0, N'iAêMåâÊ‹wZñŠD…9"iÌrÉ*ï.4Á\£L©ÙñLÒÎ!ôOá ÿ»£euOA0uÇk&jg')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (290, N'Isabella', N'DAmico', N'isabella.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'³ŠÓÒÿOuå±nÃ“¼§¶*yÂ™}g¿­D) LüR½g5„Œ8U?LÁ9R3Ô{J¾-?_Ï	]Gv')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (291, N'James', N'Battaglia', N'james.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'¸R»D!¾°×-"¥ãÝ¢È½ù@eí£ÏŽ9GBe†Ï±
¨wrB†âë)aÅS0·±dÖdvþ[n‚f°Å')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (292, N'Olivia', N'Rinaldi', N'olivia.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'Yš`Ž^íÉüt÷}´›¬‰*¾	E9¿ÙÕÜÁÉÓ•5>Gga
y·½ì‘­÷3ÄúN-·.~S¥“ÈµÂ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (293, N'William', N'Guerra', N'william.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'ôÇóZ]Ž<_*—ë¾6J©öHhüßûíd)Ì²Í?*ÞZ&®xÔÈÜ„×G6ƒ¡oËS
 $J¤âîKTNŠGˆ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (294, N'Emma', N'Marini', N'emma.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'‹¬È‰DA„èTVÚÛ®¨:xAÿèD]É;›[êfC]ïw:q¸æ‹Ójî…2~ Mkêh;áóÇö›’Œº')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (295, N'Noah', N'Caruso', N'noah.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'ùÕcñÍüV¸cúuƒ;©€`pri½…¤å$ù-Ã±•Î¦jxºÓœ¿×]h¶¤1÷iÇ&¢ÇtËÌ­ÉïGè ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (296, N'Sophia', N'Barone', N'sophia.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'fÁZF4æ¯a¼‡—›kõ´ÏË(YIãå§ÏÔ"cËåÐe—òIB\ `ð—ßü+2Uï¸Nn#7£½ñê¡´]M')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (297, N'Aiden', N'Valentini', N'aiden.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'õ_`
)
î/µkÀO;ç—Ž>>¢8øzˆ$Ö5öß©ÌùºqƒxÈ©6O&ÁÁåÏKý¦X@H[UhÕV§ÉÝÍå')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (298, N'Isabella', N'Battaglia', N'isabella.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'yÜ#¶ o…K­|°¢<ºêÖHÿv„i—ôvœ‹„¼ôD5Ð:×ÂA&þàì7á"‹+‹Ø`^Ì"˜å@ïÁ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (299, N'Michael', N'Bianchi', N'michael.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'\Yþ‘ÉÏ\+Ñ¢¦ÚžIµøLˆ}©o¦øk°µÌ¢«Z?2ÒC$ƒ“V”¯¾YgZtú¸2ìT~cúš')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (3, N'Olivia', N'Williams', N'olivia.williams@example.com', N'6665554444', N'789 Elm Street', 0, N'*dÖV=—)I?‘¿[3eÀ§¾Ä^°®gã Ã¾ÑÂŒû%ŸÆ¾vŠ°©b±âÉR|_!¡	
››-•d‡ë—­B	')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (30, N'Daniel', N'Turner', N'daniel.turner@example.com', N'2223334444', N'789 Elm Street', 0, N'¹ZÒÂœH¦õ¼‚í²ˆªçÉvŒ°¹ç®âÕq1þÏÃzßàwGÕ•/m‰ÓÁ4áS›wxžÅY~‹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (300, N'Evelyn', N'Leone', N'evelyn.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'!''Ðàbù+kïÉ™õÚ8òŽ•îü2uh#¯ -–ð#ÑMÊðmk L
uEØ\ƒ‡×¹h4›‘?ØA²RÝ­ù')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (301, N'Liam', N'Romano', N'liam.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'ÒCÎûAÁ$h
Õ‹qÿªüêŠv´ÈA‡ŽÀ\_	’uòE“m¬%gï&´Úêh¨yû}ÁÄµÒ`vu$÷')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (302, N'Olivia', N'Ricci', N'olivia.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'Ñx·Â=2*ë¹•É}õ––BÆÔ²š>p©LOKd] ž÷„³„¼žY3Dª|¶’„0sypùŽ“˜¡PfmåÙ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (303, N'Noah', N'Sorrentino', N'noah.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'uŸÄaÊ½ÚhU‘3
v¤—V¨Y\Ë‚™o`¦ª&„É\Ý©S
»PÝwå×
¡søGv—â=Õ7!0Îð')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (304, N'Emma', N'De Angelis', N'emma.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'°ÊÉs%˜®>\Tï2ÁëêK¬§¬Ó
õRÔ\Ó<ªSå¹u XM­uaêÔÜÞ

ç¼®>ªâL‹
±Ë')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (305, N'Ava', N'Marini', N'ava.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'·ÑÐO\úY®ÎG8iÂQüâeg³â‰u''cŸ|)Ø„”â‡(åÛÇŒsT)ØBëáC~¾nÇáÕ©
Pxy	')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (306, N'Sophia', N'Lombardi', N'sophia.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'à`\`w)09‘•Þ‚¼bM&c/?|¿ïÔÁ¦Õ)0ËñþöîyV”áQ¿¹;^7¿3K
àÍUxj')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (307, N'Jackson', N'De Rosa', N'jackson.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'5hzòC#^Òð¦îÕÃ¶³¡rè‹ErØ—°qž";:fFû`ÞV)œ¬«wvF=2m<é(
2U:€¯0-s')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (308, N'Oliver', N'Russo', N'oliver.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'@7]RmÈfea"—t¨Ù¼¨1<µ§‰0õPOóÝ?<¨„|¥»k2Û³„À’·%³½·EÿåØt²×%ìz¤')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (309, N'Avery', N'Ferrante', N'avery.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'j…>—±,ÎŒ¥«QÚá‚õi8³6õ)HCÀ~ d}!¸wÛ)‹úI²‡íá]­;Gåqn¢Oê¬3U	©')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (31, N'Victoria', N'Campbell', N'victoria.campbell@example.com', N'4443332222', N'321 Oak Avenue', 0, N'þì2@Î„oÆ/n?2nô³0ýÉÜ:¼±ZÚ‡~Kˆä| ¸¹=Î®(

ÑÝË4[‰Iø7†ƒÖË ÔW:hÏÉ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (310, N'Ella', N'DAmico', N'ella.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'.×qÒrDÍ8\˜ÌL]9ÐÎd^KpŸeê+õlšjòXpéi‰…bt•ï—û#[¢‰¨DâŠØ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (311, N'Lucas', N'Battaglia', N'lucas.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'CÐòhýÌE§gÛ¸+KT¬6êŠHN “üUY*­°I…½‹°Yí¹)ûÍÊïŽÞGQ“á¶ÊLd\Ð°ÝqcsïF')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (312, N'Sophia', N'Rinaldi', N'sophia.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'¦eŒçÂ7OrmCøø¿áÓ:´H:l!&8SB%ö»„—´¶gò¶c¤—ŸéáÏO„C‘ØB+ƒ°FaXB5')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (313, N'Henry', N'Guerra', N'henry.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'Ÿ%ÿmÜìˆEg×« „¹Ç KüddR¼º†U¥½›KW°fu::EMý”³·TWÙ1ÝÓ¸’7ˆiÄ•d')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (314, N'Daniel', N'Marini', N'daniel.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'O¢¸½ÉØæ/(H-2“ÄfvŠ”)ZáÏMå©&LÛåéUQ	ÞeÅÙO=ÐLòwf×'')ø•
Ç')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (315, N'Harper', N'Caruso', N'harper.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'ÑŒ I¿†Ã·¼1LdO+‘ÌwíaÿÅkrÀqþÏ1rñ  Î‹jÒ0üXÓ¾œúp¢2-Hßéþ[')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (316, N'Ava', N'Barone', N'ava.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'JNN×¾Ì6>qË†IónõËîj~6¯ý¤Q›¹˜j[¸È ‹ym]ç˜àº¡5Þ¬ø&
J;.]à(úÕ³6')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (317, N'Ethan', N'Valentini', N'ethan.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'Œ /÷w\½O¼V„·Bµÿî Ýí’&M­_ÇJ8ÊÐçzŠsXhDÆ‹Àô„.e¾óÆý×í¬Ï0!')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (318, N'Isabella', N'Battaglia', N'isabella.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N';sŒ­Kç•m`Möù-]–¿7·‚¬´WÂ÷ÑÓöÀÜÅÅëpÝ©¨92s²•§-¶’c¥å?œÎVÏÃÇûŒd')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (319, N'Mason', N'Bianchi', N'mason.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'¸‡¨Ey%Ø ·wi¦+Lú«hQôÈ-{@ô-V"ƒ]&[E@YrÖ?op*ÝÁ¦ì~£¿zÛã''{éz}f—<n')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (32, N'Jack', N'Perez', N'jack.perez@example.com', N'5556667777', N'654 Maple Lane', 0, N'!T¯" „Ó0IÁP*c[ñ7m›KÞ™Ü!‚BæÎ”M44³UñøÃJ°¥zæÐÚ`…½~;¨¹Ó”?-6†')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (320, N'Liam', N'Leone', N'liam.leone@example.com', N'7778889999', N'123 Pine Road', 0, N',q¢¢ZÜTf6hDÁGâ{èFŒ—:‘rSS@„]G–wŸ35Ôðg@Ú¸ÒƒÆÓD=Já§;W<Ð¦V„')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (321, N'Olivia', N'Romano', N'olivia.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N't>„“hØåhËÉWY
Ç8$mýV£ÈÔ,H9»³„ªyû5¬Òó‘}_FÄB”coJ³Qd}úuV¶ À')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (322, N'Noah', N'Ricci', N'noah.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'õ×hxù­FùîÿCu''¸‘×¥qëomcï=ØŠÞùÕ«î!/Coé£í²Ã/ÈrLBPSá£dQ0†5K§«“')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (323, N'Emma', N'Sorrentino', N'emma.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'±n
ÆXBgôÚª< 6Y®Þ›3·’sîóë>˜«yfÀÖâ¥¾áÒvž/þ q+¹þ5Èk=ò>Ê°Ð¦méw½')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (324, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'$Î}PE,?!z?^¢Ÿè¿âl#8™»©;£á*TïÜ—eJîi·2¶U•GŠø¡êƒmi¿þVÁUuìmvé')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (325, N'Oliver', N'Marini', N'oliver.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'Ì
:¯©ƒ%ï»0.fˆáÛ˜«E|@[GGšâ…}X*?«2}z§ôu>nfð.þó®Õ™¡Ù£

')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (326, N'Ava', N'Lombardi', N'ava.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'½X–Ï±¨…(­·)°Sï9©¥°\×ö¶™¬=~
]ú
s@Q®Œ!)…|A%’ƒÏ¶é
™Z¹¨Ò½ñ÷‰')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (327, N'Sophia', N'De Rosa', N'sophia.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'²Írl¹ÒdcžIu^Â,˜QÒ!¶çôœ”^‰É
ÑÐžAïyª8C•`¯Ãã:¡ÊžIéØÄòQFbcß]')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (328, N'Jackson', N'Russo', N'jackson.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'ÊŽº(êWaõ¼¶ûŠá]Ø0h®Ð¡úþr3Œµ¶+ûÎþUòÖ6ÏZ¼<‹^B)Ôõú SÙeV™E¥@ú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (329, N'Olivia', N'Ferrante', N'olivia.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'‰íxÁv€ &ô…&,÷Usä²£),Ô¸¥+‡©æw^¤JTšÊoºü§Æi°¨„§$;õýùBD©¤FòñL')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (33, N'Grace', N'Hernandez', N'grace.hernandez@example.com', N'1112223333', N'987 Elm Street', 0, N'\<ûŽ”¿ì¹ÞS<ÞÝ-WDB÷L I³šOäXÅÍ 1ëó‚×þ˜³¥d"ô¿*§.Êx†L
8lØ°¤I|ÁÃL')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (330, N'William', N'DAmico', N'william.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'ãúôû…¾Š0S—†X¬c… @Æ/êç³†
›±ÛÔ>Î$Øƒ.3æØøãy¼Ë«ú¸dYÃ7fÕ
•y€ëh®')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (331, N'Emma', N'Battaglia', N'emma.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'^OËŸ¨]¿áZ•(ºÙ,0O†y‘XÜ¥	.á6µµ™>*$ÛMü®éÛ	BÝ±ƒÒ
9q¶†2ž(ÉÊ€.#C')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (332, N'Noah', N'Rinaldi', N'noah.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'æU %Îo¡°âý0~õA½ã®–‹ ®ªu‰â´‰6X›1mX¹x’›29S—øˆ(Ëj+‰Z¶''¡Ìµ¥')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (333, N'Oliver', N'Guerra', N'oliver.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'§8B9E™¦Ð¨‹FÉkJ„íc>o¾ŽŒÛ*W˜PQRÌ|R–<™oyù¶KIú‘Ë5ø5°ƒ	Ã`8—÷')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (334, N'Ava', N'Marini', N'ava.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'Ënû÷fø/¨òdd×—”âZêç`£L6Ê`qýh—µò©i0Vp›Ð^³ñg¼†*‹‚¯šË''iˆ¼''>±î')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (335, N'Liam', N'Caruso', N'liam.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'›I¿ç,º‰ˆ‚"õ*÷óyªÏ''c!5öËfKºd ÀNKòÜž¸$½>‘‰™
4ž´jõ¿~BÂºM`JW¡k„ôG-')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (336, N'Olivia', N'Barone', N'olivia.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'ÿ½¥eEÆL™§Â)Oã=SØÈ²¢FÙFY;žˆó€zŠèb²PG,«WUF?ÚåRÅ!s-YÔ,—rÒ=è¸8')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (337, N'Noah', N'Valentini', N'noah.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'Àü¬¶Œnkè9oøøÿR[ïàÈ`öYÐÊ‘^&!éä‘²ÍüIS«õdª²ˆRá‡U~…FŠ¥Ø¬³D<')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (338, N'Emma', N'Battaglia', N'emma.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'S¶Ñ¦–ÖÍÈõë¯G«Jœx×é±¬jÝ›3e‘ÜìbFòTaÚ§A–4÷Ã½õŸ,ØÈ?‡wÿB`§A®è;')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (339, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'sŒçR]îfª¹”Ëƒë¥¶Ž¶5§}*1Ç–ãŠëåzãr££í·Cv"Ïìß í
/úðy,G\Ü.+ìáæà')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (34, N'Michael', N'Morgan', N'michael.morgan@example.com', N'4445556666', N'234 Pine Road', 0, N'ˆ?¬?gù2ŸXEµF à@&®¸ Í13,¬ùÅæþ‹eP2d“>äK«	ñq»Ž°‘š¸úóÚ·æZ0ÝêÍ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (340, N'Ava', N'Leone', N'ava.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'Õjh Mëfï¾%b}ÇIbV´z­srK¸†Ÿ1@Ë›M©\õZ0p‰Jf^!ÐDÈÌ CWî<ºÍ‘»‘Á')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (341, N'Liam', N'Romano', N'liam.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'÷º7åµ°dïpÜÉÌv9;ŒÉ2¾È¦ÊºuîÈ
÷7F‡Ãt‘PðCW{_ø«Ml]$=Ûg%ÌºÔÞÛ[')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (342, N'Olivia', N'Ricci', N'olivia.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'¿ÍzpH"^¨„«¢œRë»I''ç-½¡`''²²5ÁLX)X•íPûœµÒ\ö,ïËQ`ÉÇ·kÛÓÜ8c±R')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (343, N'Noah', N'Sorrentino', N'noah.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'=¾r	ÎáŸV''žƒí¯0t./‚öÌ5LœÌJÄ¬:Ç
—2ê½ ³zß ÔÃ8æQ-Í×´¢ÇNÆ‹Y')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (344, N'Emma', N'De Angelis', N'emma.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'§Xñ—.†•áx`ƒM„è  myCé‰	á³”1@Ø÷*¥¶p”N
Šù³\-7èÌÃW“/¥·^UôÑT')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (345, N'Ava', N'Marini', N'ava.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'€­F^”Á•qš¼c)TÉ“ò$9ó™Ò`*L''´¦/ßîy>Ù½ƒyÅC´‰çc	Ds4Nœ{Ã£žž¥H')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (346, N'Sophia', N'Lombardi', N'sophia.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'³ºA‘ mßA)[Ãæ%JEäŒÍ€s*–Öü?­.•Zã–ÄDþ1¾é(àLÄ¹ Þëz9“	´Ûµ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (347, N'Jackson', N'De Rosa', N'jackson.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'š,¸ygäóÛô5ÅåïÅ˜<1''‡Õ+yÁ&Áºé·1æ¬¦€ø˜£ÃŠ•È°òánãmFÈ>þ®âä$')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (348, N'Oliver', N'Russo', N'oliver.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'à0¾c^i''B×¡\b[‹
^œþêàü&T¦‡•s+ìRbažÃrT/fZ‚&í‘³cpåJ­‰§')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (349, N'Avery', N'Ferrante', N'avery.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N' zûG&…BÏc•ý Õ5æ²eíœ›%‡x„°ä/2@¨MªBÀ.ã¼%ÜŒ„ÂóW/•ÂiÌ1i°–ÉG4')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (35, N'Penelope', N'Allen', N'penelope.allen@example.com', N'6665554444', N'567 Oak Avenue', 0, N' é±ÀÆFüù=°î3§È”ß¶Ô»Sé	H-}*A\<i©ÉÒ“Ziå ÁQ¶`}fQyá»æË¾V·')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (350, N'Ella', N'DAmico', N'ella.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'ä¨ôÓìßY§røÖ$D7,}ÇÇ¡bÜðÓ¡™c•‡
¨K¡1â®ÿÁÆâðIËûôëÐ¹3r&ãjÒ”ÏJ¹¢&¬')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (351, N'Lucas', N'Battaglia', N'lucas.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N' ¤øö¤oÍO–½„Â¤‘ÎT+#8‘.Ep6I}j†¥{h sÛAòHzWº|%š“c]Œ+óíDUÙxØf')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (352, N'Sophia', N'Rinaldi', N'sophia.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'ú)SÌÔd`5ßMTrÖÌñxXL^‡þ¯èilñ™þ''ÑÒÈlú EýY]7{s¸xI‰ñ~ ó<Ê')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (353, N'Henry', N'Guerra', N'henry.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N']­TÅë«6x’g£JW”€ˆ¥rÇ·µIî—¿«ªŸ|¤Í6ÜÅ#Nãƒä¬[Þ˜qñ=PÑâÇMž×u‚ç3à‘~á')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (354, N'Daniel', N'Marini', N'daniel.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'dLm¿lãí2ÀZ0­é2¦‰
óÏâ5„$#$HöPynù…(&Ã˜ÜDºRš*n%=Âajr`ZÊE*K‰(')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (355, N'Harper', N'Caruso', N'harper.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'œØG"™~äRx=ýû*¸Þ0gšÚGË¯é%Ì’ô?ãIW‹oÛ‚>‚Œâ°òéÿD\Å >ƒ*…r')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (356, N'Ava', N'Barone', N'ava.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'¾.Ã/¦ÛX`¶˜ÔY§ƒ²&šâü‡^–~w.b½ÞÔ“ØnY5°|ÖSéÞ3yÁð>D1…´Wî')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (357, N'Ethan', N'Valentini', N'ethan.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'pGæòG×õ”žXf¤!&5%7¤ª¿ì›·Â«hq©×¦»TªÎúsÅC
ªCÔe™''ÄÈ¦%­8¢{+Åþ‡ü:Z')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (358, N'Isabella', N'Battaglia', N'isabella.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ÃÝN1©ù»º"lóŒ==0%lõ‚sL3È†è)IN“‚³Š„»TßEø¥Ù3Û_xv®‘‚qÉê''Æü£Ï[a')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (359, N'Mason', N'Bianchi', N'mason.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'¨®ªhE—jqÓó6ÉÜs-Ô°ŽýÓ;Åe+‹±M· æÔ’P¥·™#áR%Àh}ê‹^Ë#WAy')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (36, N'Benjamin', N'Cook', N'benjamin.cook@example.com', N'5556667777', N'890 Cedar Street', 0, N'q~Ç
/kž°+ôÕ­º¹œù>¸"@—€qµ"]~5fòBcT”ƒÚ
e7ámÞ±-¿2''\†¿éÌNê-ÄÛe')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (360, N'Liam', N'Leone', N'liam.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'¯TãÅÙ©#í|K|+ÖÙæp”ˆÎžæRº Ug¾lRº¿þ½;bÎÀó‘üÈÓž"ˆº3“Ÿéƒá«')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (361, N'Olivia', N'Romano', N'olivia.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'Ä,;št9Ó`ék	¥gEw®ÐØ‹\ wýÄ­–Ø¢M`åÑLdªp§´å•-
ý-Ìœ=ÐôbŒ+9(>')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (362, N'Noah', N'Ricci', N'noah.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'Lq9E•ï[N$YG…Ä~ª2¦Ýü.inñ‡©ï¨£ÐdS_zºOsí}Åy­nŽ@„v’œ9m_')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (363, N'Emma', N'Sorrentino', N'emma.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'¸3@;ïÁÀèû¼ŒÌÖw{Jè-
9íI£kS1B$À''¹s¼úù æouŒ"˜bLàæv¡PQyÈ«z`’Ë')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (364, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'œZ¨-ÒÙ$½yw½‡¯&ñÿ¡{Ê :³§Íöá!VÞË¥äÁo¾E=‡,åÜcê)t%]ôT
±')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (365, N'Oliver', N'Marini', N'oliver.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'XŒ¥­—¾HÂ íÕ~"¿¹óÍH‹ô&ã¡ÚoZEÿþ]§)Q_½ÀÅ¯ ’¤›Ïä)ƒ”?»ßÃæjOÜå')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (366, N'Ava', N'Lombardi', N'ava.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'0Y5:‘oúš	û÷–iW,tã-&:“n÷‹ŒÅsIñI\úi_;_ƒªF™Ü9"nÁ
Qëjÿ¤Ù''ØÍÕØ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (367, N'Sophia', N'De Rosa', N'sophia.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'h<€"ßœÖË@”Ig9˜ª$}˜ÎíÁs*à¬%±ÊžcÖü—Ã]+ÀG?(d:ëÕ×Ë¹6;þÑJo')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (368, N'Jackson', N'Russo', N'jackson.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'ÞŸLGÜ4\²Æû¿:ð
â[
Æ*o‰è¼‚)—õü„‰Œ‡7NÌCŸC"MìØ%5#RÕ2öµÿØ®{')
GO
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (369, N'Olivia', N'Ferrante', N'olivia.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'„1ÌœlÄ­¸Š|&,™¼T-MM
ÜÍ&~î0²×°gðÕ™òÍ­ÍØm¾Ó›õ/‚LŒS"õTô')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (37, N'Nora', N'Rossi', N'nora.rossi@example.com', N'7778889999', N'123 Pine Road', 0, N'ðÒ±·E#D*úÿsˆí/¦šPd`¨T$y¸•=8^ö	–±)½‹^ï­;\¡‡‚ìG
	7 4]^K‡¨ ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (370, N'William', N'DAmico', N'william.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'5Q™Èsé
#5$¶÷ñ¶é/Â»
î§_„$‹Ÿ… ±dû^í
£Âãt­¢‚V±‘3ãF›œó‡¼Í	')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (371, N'Emma', N'Battaglia', N'emma.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'0†ÈMó6EN×LÍöƒ™©lÄWºýAµõáÉ;À7AÝ‚HÄú#‰ï2h­Ci.{ý]ÃŸi !ŠÙ ²')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (372, N'Noah', N'Rinaldi', N'noah.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'²çl›Yã¾	Ä÷}ç’Tç.B]=ìm)b¡LŒ½è• ¬Kko.°§R¿ë
j	
;‚Õ¾ör6Hé`B')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (373, N'Oliver', N'Guerra', N'oliver.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'|m q¶Û§vn“¸ûK\ÖSNèå„;áˆ€Ú-®u
Ùª5Ùày·ÔLFïP÷ÎP•¤!µ½Ç&]Šý·ì;êx')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (374, N'Ava', N'Marini', N'ava.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'°á$šÙß¤ûFX–Ö¾ÊLy‰˜nõ¶·½u§q=Ö@ÌÙX¼Þ°i‚¦ø<ö>°âMÿdmÖÏgÁ?''ë')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (375, N'Liam', N'Caruso', N'liam.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'
K)Îžo“.‘ÇËú¼?¶LŸÜ
;³
ñ­>zá«¢¸ævrsÑ*>75q“ÃßÌ7økU‚ù$x$¨tÀ³`')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (376, N'Olivia', N'Barone', N'olivia.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'~çç¤ç
òÈË;nýöÃÉ*!N¬{Â‚Ò€ËKíÃ¹¸1ÚqÎ”J™mRæJ3Ã|¿ýêA¦/Yºïà’ã')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (377, N'Noah', N'Valentini', N'noah.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'é\¡ <˜*žƒÉÁß­ðdc4³°M6"bü
ÖïÁ˜wÞdC ¼õôn©[õ™e¹MrœÓ\¦¡åÔcP±‹	')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (378, N'Emma', N'Battaglia', N'emma.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'Qä(ÑH}I UlªŽ‹ô`ûŸl<Ò›™§26=Dg
 ô³,±˜ãUp‘…	ÆÔ;‰	Ì9½¡Ú3Ó•iÇ@')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (379, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'YIuûN+†˜Ùóÿ3—¸šª=Å×s9’ÖËvÞÜlFp•é·Å:‘tÅ†(Þ=àö•ÀPq]ÜÄ¾°')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (38, N'Leo', N'Russo', N'leo.russo@example.com', N'5554443333', N'456 Cedar Street', 0, N'dÏ6f9£ZÃ`ðürtÞþ ´ÄÊ$ð2zfPÍ®™Å¶å§áèý–vLŸšÚrMÎ.e‰½·Üq¨ŒÂEã')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (380, N'Ava', N'Leone', N'ava.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'ÕÉQdõ­œÎÐ`MŠh‘€ä5ÉŸ[ÁßªÇÑ–Ét¨@o%Qx$æAïŒDúºíãiˆTB.o	#V
')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (381, N'Liam', N'Romano', N'liam.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'˜H³`×ÔÒ’0Œ…#,Jkƒñ‘4†¥;2
æµ×¥£×£‘”þæUfØH–×²]";F¦™ráãféñˆ
')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (382, N'Olivia', N'Ricci', N'olivia.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'bø0GæùóËnJ˜±lƒê˜\4ï”jÍ[_D-õË—ÜÒ©--œ·Ó¿*
’MŒ¬¨½ªGÑ*Uƒt(«Ò¡tsÇ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (383, N'Noah', N'Sorrentino', N'noah.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'ÄN|i·1žL‹ow’–ä–Ì¢ êÓxèj¹,ˆt ñ1xKÏQŠtß¢4 ¯sá3ç€€ô~a
)X')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (384, N'Emma', N'De Angelis', N'emma.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'R®	§>î
	 ¯·þa''0aåõDøËàmc«è¶nÌRbœ€]Z#~^„û„r0Zúe¼½çAwþÒ"Ô>Zr‘')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (385, N'Ava', N'Marini', N'ava.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N' :Ú°”»in<k€†ñ• ™ùRjÚAz`SpÜ{ž¬×B‡3•€Ö”+Ë~aKù^2ûw	E-«Yú7ò¶›')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (386, N'Sophia', N'Lombardi', N'sophia.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'³wâŽ:"vìQÆû¾d÷²šû¤¸eÁÍæ(b¶ÿOÚv^®ÿÜ=1ÈÁLZ~¯?‹$—½Ž0Õ}$¸Æ2€¾ãó')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (387, N'Jackson', N'De Rosa', N'jackson.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'Óc çD
¡
ã=öZ¿g1óLª©aMâ êø)ómO¶ÏO¦Í@úxÏm•BÊñdÔþ )cÚâ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (388, N'Oliver', N'Russo', N'oliver.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'$©7Ò¢¬ìk½¬d#Ÿý-”fÑ7à5È¬;Ó2B	þWÄîóx gA-³“ÞÑcƒ*2¯<©ì4šð±7-:')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (389, N'Avery', N'Ferrante', N'avery.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'y:ŒO„ÕO5*µ”FFFÐ-$Sƒï	¢¨Ç=“™sk-ÌÂÕ˜ØDÃ.¢ÀÕïãÉõR)³/<\T«q·vKP')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (39, N'Madison', N'Romano', N'madison.romano@example.com', N'2223334444', N'789 Elm Street', 0, N'†U÷{aó7¬í _š {Òÿ–7Âªñ©—Š*gºw· O~y¨BrÜ~(¨î4±†® ­ã(DnÝjƒ ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (390, N'Ella', N'DAmico', N'ella.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'±z1š.l€ÎcX°Taî''l{~NkßTCV.½¡T>á?ÌþÌx/Ïý¼ÐôØ¢3¬ NqçÍRƒ‘÷n')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (391, N'Lucas', N'Battaglia', N'lucas.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'{³èdlgË«vÍO"4MHöø­¶ŒJpm³Êpëê3öÈ£ÂbµX¥³ó+ d½…²S‚BèB» ½·ÑmÊ}')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (392, N'Sophia', N'Rinaldi', N'sophia.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'Uø"Âð]ßtÈ=?§·Q”Ù;ƒVÉpB`
>±Q+ïmÞž\{‘MéCJ|¼¾¯mÚ]¹q')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (393, N'Henry', N'Guerra', N'henry.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'x¡nž@òY,ýêÁ1µý¨ŸÓ~dà‹&‘ix y©= |£.‰÷ØùsS%ÀFá¿¥ˆóš/¸DÀ…ÿ{')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (394, N'Daniel', N'Marini', N'daniel.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'b‚ü†q0¯å)
‚%>Nôµ\ûwªbTY(è^Õê/,¿%@—Ä®ÜY(Á½nÃ†Æýâá™^BO/{ë5y')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (395, N'Harper', N'Caruso', N'harper.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'cMúçéú¡ÄÈnÛ†“‚ÁôF(’³ý,€Ùüèó{éÚ®ÙÔ…?‘#‹—ÔQ·‰oÛ£ú<ØÔ£)¾')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (396, N'Ava', N'Barone', N'ava.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'±¿ƒK,b4àmÐ¤³—Ïaç ´JQX‘¯ÐR¿’ªÆO	Ï¿è¼3>óž¥ þËNçO,‰Œ¼Kg…è‹þ1lç')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (397, N'Ethan', N'Valentini', N'ethan.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'Ñek¤uëŒ$Ð—ó§ZñwS›DÄg!ðL  ÍIœûˆð7ñ›''Ÿû¯Î_„,¶—ÖºRªUÞvN@¾¨•.v')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (398, N'Isabella', N'Battaglia', N'isabella.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'·À.ËËü0Ã ''|ÀO)YYõ M
C—Dœ¶øäøê08¯|jéFä1~Kãø÷ÒDm''îû¨Ðž>b')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (399, N'Mason', N'Bianchi', N'mason.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'ŸS%ÜÜnVì)¬©Ñ£ýÞÖÄ{ÆS¿-§:5Ò©¢³ÍÇzÒTT¼{ë£m«A­ð/„´geƒÛå©')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (4, N'Noah', N'Jones', N'noah.jones@example.com', N'5554443333', N'321 Oak Avenue', 0, N'–½Nò6H¯½-\%''„‚qGñsà­¯
³ŠáŽUgÆýîP¤Í5ûTK<YN}g~ú| *,´±+')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (40, N'Jacob', N'Lombardi', N'jacob.lombardi@example.com', N'4443332222', N'321 Oak Avenue', 0, N'Êº".ØoÌeûÏóÂb…÷Ý©Õg‰“Ö¨qý×ëîÆNdè8Ju¦ZXïn«*+/g´Ì*ãK©m
íÀŸò')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (400, N'Liam', N'Leone', N'liam.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'èÙ½NVt¶4Z›#¬	#¥º4ÑãäxY®)>¨Þö››q5¿x¥¼l›³r’¨m«¼§L€ dÜÔºŽÜ*œ#™pQÓ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (401, N'Olivia', N'Romano', N'olivia.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'FFø\2a)û†oƒoÉøé¡1ÂJ¡“
ö}ø‡õwp®wÒTó0ÛÚ:$ØŽOò–CœZ!\)Û,©y	sª')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (402, N'Noah', N'Ricci', N'noah.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'‰''-N¬  D²N,Úá/#Ì3ý-üø.…ûŒé«ÞgòcË`Ö–Y½„në¢	náÜƒ3
bh»ò w0÷')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (403, N'Emma', N'Sorrentino', N'emma.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'‹ƒQ`ïó²\YZ†°v`G+¢&§rÈ}þäu¯Ý
9Â2Œï/ü€¢XœÌ–^ýH5rI^é¬l?È £F')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (404, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'•?%)@Xs’£Üçâ~YÑý ©[·æðï—o+\<äíŒ>4¢ÂtÎh^æU­„ïšÇA¥@Î†ñ›')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (405, N'Oliver', N'Marini', N'oliver.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'KK¼Ä]s,3Æð©,’fp8g¦°«µó^,ãPûQÜ%dT`L¯8j©1ÖPJfŒÔýç¾TS•ªöù')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (406, N'Ava', N'Lombardi', N'ava.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'52ðÝ2¤Ð» K)ý˜?|§+žw>O¾‚•ÂË)€,Š‰}¢Jk¦"‚ùe æ+aùÂ ¤Ûï×')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (407, N'Sophia', N'De Rosa', N'sophia.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'ÛQˆn_ˆÛCý‚dÂFKéŠd½~”ò¥H-xemÜ[1G¾˜JTdˆ#sVràÐÛ†11ûa†a^LB´Ø')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (408, N'Jackson', N'Russo', N'jackson.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'–®ôV–óÁ¼Øxu—üI[›v†µö–ÌÍÙg3–CE©nÞh Q)Á^Ðb*Øñ[²ÎøWèÈumüë¥Êå\þ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (409, N'Olivia', N'Ferrante', N'olivia.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'@UÌÅ‰L¡wƒ6¶ÌGÿçI°þ·BY±L]z= ‚µˆœx9A
âOÕO¯%7¯Ó©™\Xš‘U')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (41, N'Luna', N'Esposito', N'luna.esposito@example.com', N'5556667777', N'654 Maple Lane', 0, N'•?ÚÖá.X³bO2³¦çÔ.Ô·YnZÆu¡¾oÏuOtÅV_‹Â»Åþtþ¼p5Ó.«±7?À#¯')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (410, N'William', N'DAmico', N'william.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'Ï˜s•Äodçrãêî0C¶â²jòøB—RéÛI.Ô8›Àa³uMÚ
LÛì&ô‡Õ°6"ëOÆs 1ír;Ì')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (411, N'Emma', N'Battaglia', N'emma.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'ä¬îèþÄÒ›¹›¯%8‘5ýÔt¤È©±)#—Ä>~ÏWë9œa,#øRÊà/‹tÉ?t6\$=¬vß7=ü ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (412, N'Noah', N'Rinaldi', N'noah.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N':6W3³ãßad+áÁ×Ñ:+¨þ‰¸¸Àx5m,G.1½BšVUðèêÈðtHIÐ!	s­<ã$M$
„Pc')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (413, N'Oliver', N'Guerra', N'oliver.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'Yž7‚Õ8-MÐÂ{äèç2ƒd!)¾¾©JI…`Dµ¡¨&ò^ÌøOR’F<qjk~žC²e·V‚ÜHÆXÿx')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (414, N'Ava', N'Marini', N'ava.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'¬a¤k¹ÒÒ©Jùyï¹ÏçC5¡!îÅÏJº8¿t‚¬Ð‡)aÄ>Ëôâ÷å+þDö§ƒp;ÀžÁº×x¿u$')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (415, N'Liam', N'Caruso', N'liam.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'‚× è u´ª:¢àeÝÎÂµÓLô.ïµ6Il4&–ï/Ò¶¾æö›Š%4ïVí¯ã€ZZ‚')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (416, N'Olivia', N'Barone', N'olivia.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'naZ‘Ç¢L±06[2í‹Eæ³ƒN²ó*›oYRA‹4ý¹Zê¨Vå’õ@ø@mÄ¸—Î‡cêË…¥#î"yP%Õè/')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (417, N'Noah', N'Valentini', N'noah.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'¹yKÐ°p_ài³ÎŽfµ]ºåØ¢¹ž)+½ED)áF¹c‡Ÿºä„ÞqŠz’ÚÜÀ¬B‘²2·¿ú¡')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (418, N'Emma', N'Battaglia', N'emma.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'²d:8pkg©ìUÒ>t
‹¬ë1ÀûY‘@š7w¤¶ Dü²ÜÏ&¦{Ì>ÿàƒü…6¢i9—Ü½lÖ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (419, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'ïâñ³ÊÄ(Ý³îN£…§°Ÿ<’¤µq·7©×4]SÐS]°xeˆûyéŸÙ›”ç¸bs
@Í0É9í>H(')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (42, N'Ethan', N'Conti', N'ethan.conti@example.com', N'1112223333', N'987 Elm Street', 0, N'QKÏö0¯%!¼ÂU­‚I[T‚V`­©÷ðr¨£^Äˆ05¶+4¶îÜåc˜=y|©æœðœŸ–0Gì–Â‹·')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (420, N'Ava', N'Leone', N'ava.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'´6•~ë2=«,ôè§uXúuœËÒ‘´Ívªµk‘á{j
€¦%S¥_–2¢«U2ßâÓ‹|ì')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (421, N'Sophia', N'Romano', N'sophia.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'‰÷°áää‚QÒ³8ë_ÿŠœOoº2n°øÝ;àñèÈJ›:0ùñ¯KÏÔGr»ë¸áµÏüÎ Âo˜²')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (422, N'Jackson', N'Ricci', N'jackson.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'p8ŠÍåÓßŒ™€FþŒX¼ þw®
—lsU®~YìC0}ïF°bò}…ÓŠUˆãë^6¿XoF¢\5D•u9')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (423, N'Olivia', N'Sorrentino', N'olivia.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'®C‹ÆBì ›WôÂú_Bs]¢Ç¤¶8¡Íû]ŸûAõÍ‘_F]à„>+»#‹¤ÂCCa‡XunpåÆ¦§2L')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (424, N'Noah', N'De Angelis', N'noah.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'QÊÜ$*mñs§Ð^Y”¥¾µêoÑËä±«Á2Ï)½{î¼à¦ã£ñïZ‰$äá¶Æ×ÀrµiÁ-')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (425, N'Emma', N'Marini', N'emma.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N',Ðü¼2Å/£*Œ¸@H§òÛÝy3ˆë™_*rÌ_–C™£y½˜6ýw ¢{Ö©)T#ëè–1Ý¬')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (426, N'Liam', N'Lombardi', N'liam.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N';M¾ÿ–_ÕóE nU°Áç/¸ àJkg…''·Ÿ-WâÅôc·«pÐºÍˆå¦£‡ñ#ë!.ŒGlm*(')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (427, N'Oliver', N'De Rosa', N'oliver.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'©#»ÎþÚ 	hp¿¶Õ+ë#®Q‡	Œ9›“¹BB3c*±+‰«ªÖ
my-Á>®Åfëñáþý;”ªp*X')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (428, N'Ava', N'Russo', N'ava.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'%™P¯‘úŸŠê†7â1d™ë‰sUÿ‘ÅÞ¤²Ù_Á&t}­ojq
±ä1›VYCJó›cgæùkœHë{')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (429, N'Sophia', N'Ferrante', N'sophia.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'0eÆÛ€Ë®Ë‡Äu7sSsB^0ì$”ÁfWÛƒäHÌgöòÉìs=¯œDãx-ÑI«l¡.qçóˆŸäö–"š	')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (43, N'Chloe', N'Galli', N'chloe.galli@example.com', N'4445556666', N'234 Pine Road', 0, N't¡„0³ÀBz¢îï—ŽM÷e¾Oc2ÁGº•ðãs<Ê^Ua%\sä1ˆ•Ëë¼[Ÿ€(Z\…ŸZ5¤Qœ£')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (430, N'Jackson', N'DAmico', N'jackson.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'öýN|
«¥ŸÙ<®_5e™=ÛŸ''iîËU"-ü¹&@­÷¦3Þ UnDëÑß}^Žb·$Àå')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (431, N'Oliver', N'Battaglia', N'oliver.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'a¾•Òá‡@zÖ¦9}ÊgJàå2åéVO*®~»*^Ùzûú«W¥¾Fa5g„®Tæ>tçºýn›wlu!+')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (432, N'Ava', N'Rinaldi', N'ava.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'x1“²Ñ° S$v^n“ý):ÑkL¬QõÈdŒ"šýyžÛ|°*BõTZÃøÞ]™×)
\ÍøD}''dj|')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (433, N'Liam', N'Guerra', N'liam.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'×d´‘Ï_Èò•AðÝúÉ—QÐEð“Ö­óŽÅ|FžZý}ÓODØd¹¯g£ª,Òñ"( h75VtÂ	
P¬O#p')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (434, N'Olivia', N'Marini', N'olivia.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'ÒÂÕöt}ùòªQf˜•éxaLÊ@D\(•$ÐyüZËwiÎ\ƒ2[îìK»l[56®‰Ã
s#Õ&·4¨')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (435, N'Noah', N'Caruso', N'noah.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'˜\È	¡ÿ''‰”Â2»¾ç¶—x‘Ž,Lk‹uZq9)-¼«A ÷a¥†iô	%nÀíì%U.[”¸j')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (436, N'Emma', N'Barone', N'emma.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'« JZìq,çðœÓ4$R%®…+§ÑÅŒOüÄ;œO 5©x_+V=|Lò¢p¦ë„–5›vU€')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (437, N'Liam', N'Valentini', N'liam.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'¿#º}Éc³oÂÛ%Oó@„·sŒ23Ïr=7Þð¥+Ÿë1šüÒëÓŒ¾òa±”tÉhšyŸõ$$ƒ(MU(¯')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (438, N'Oliver', N'Battaglia', N'oliver.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'¾g÷UxçäiA–ñèñmîçLvÏ]_–:œ>i ¯)“#q‰«ÒÌ¦¾‘’ðÜg_6wæîªÒðGècs ØÅÒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (439, N'Ava', N'Bianchi', N'ava.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'ÃæÊûtT˜í+êù —ð‡{e6‰„‚Gé<‚ïÓ¯­­t''ß9C9»7''xl§pý=SQ&&¤˜4æÜ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (44, N'Alexander', N'Marino', N'alexander.marino@example.com', N'6665554444', N'567 Oak Avenue', 0, N'‚Š¶ÕÎñ`ÿ¾ëEŸRkéëCu¼T½@f´\ò‰òL*}«&à-ê_}VÛ"Ïõ&NðFj1’×Àñ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (440, N'Sophia', N'Leone', N'sophia.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'…nA''{ÑÎ–Ô¹]¶¥'';Ø«”–xß»œ|ñ¨˜.GÙ¯E‹%®ƒ¯ªt»±¦üoðÂWá
¤HE“6¥bnéºŒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (441, N'Noah', N'Romano', N'noah.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'‹“¢ò,iKÃÅ¾ÔëüAMØÈ}(.ß¨#täêp/SXkìÅJÝÏ¤G…ioå5Pk1 *ÚK"·j')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (442, N'Emma', N'Ricci', N'emma.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'4±£qúž†èÒAšk£ÌIVhvWË6Àx!¯~„¤9ôÀˆcV®UFPk:€G^YuÚ¡WxÚôL‰ÇÓvl')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (443, N'Liam', N'Sorrentino', N'liam.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'6—%ìlÄ•ßp+sm.(€ÔDóù
GÁ‹|4×/¿MØè–6ý''X)›V¸|ý!l¯øÖ°w‹JW«¶qË+%')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (444, N'Oliver', N'De Angelis', N'oliver.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'Ëñ¬67“HvwŽaFÛE#:7É‡!mª¹ïcn“''§ë‰ Di´h‚¼uuf
ÿø5¼å/N$´1ÈZúsÐ„‘')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (445, N'Ava', N'Marini', N'ava.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'‘I†¯h«:îõ•{HòqÍrc~”QŽ…›frÑÏYöX0ßj$
kÓ³ïÞ¿IZ}{ÄÿçõW’š÷jõl')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (446, N'Sophia', N'Lombardi', N'sophia.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'|£ŽïŠž,m?ržêv-èò"è1ë‰ºb­Ö$"Û+hÈË~WMöþ+ô¼{†5dŽld‘ìbˆDG¨')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (447, N'Jackson', N'De Rosa', N'jackson.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N']gšÊ§_úë–Œ ÿhYŒCM-Óê·‰ê¯PÇwS¬‘+¶–O>	Ål%‹vÅ©Ü…Wrö+…Äêý')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (448, N'Olivia', N'Russo', N'olivia.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'‹d”ëß	ñTþQFhNé¹Å)ÐCÐL •]Š[t-¹‹Œél<ªÿ¨ªá÷osN­°ÈaTû‘v´š')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (449, N'Noah', N'Ferrante', N'noah.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'£ûfždEiÙ@|mÐîÈñU 6àèöogqŠ­©*ÔýÕ˜09o$ÜØÌèê¬
îù¯¼D®Z@Áõb²±±')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (45, N'Aria', N'De Angelis', N'aria.deangelis@example.com', N'5556667777', N'890 Cedar Street', 0, N'ñÞ!Í€‘BçÑÉ»¾=$Ñ.T L<Íéiz6f˜t#@1Â,È¦™C´}Œ íƒ&è:;ðö×„OL	ÊÆ2Œ¨jX')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (450, N'Emma', N'DAmico', N'emma.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'™Ã9žþ±¬â£ýŸû6w*ïô¢rÂaáØÄoN
ù<b•”à_Ël±¼ØÏ„™tBý ¾ ’0=·UXÇ
¤|®')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (451, N'Oliver', N'Battaglia', N'oliver.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'EékÂbºÊ¥Õv(œ+‹ö3æ`šùûœ…5ºø"úô8Ì»Ðç9ƒ¸8x€mûM–VxÞÂr(XÆLþA™…')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (452, N'Ava', N'Rinaldi', N'ava.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'tÒ¼9ŒÒuB¸PGKÑÁÏnærþêÎV$Š•4šY2C^!»­`ƒ]õ‰.‘°''AOñª•¯2ßnã(ëÃç')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (453, N'Liam', N'Guerra', N'liam.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'\7wtöŒŸt2DvSMpÉ$u„k''5€d…‹PÄx¢š"´ti­‘
UÞh¢$h,˜
­‰ÉÀÒ™â')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (454, N'Olivia', N'Marini', N'olivia.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'ßŠ³TTkS•ÏÓö7æºíšâ)‹˜ÏmŽÒ|L¿ÿ¿²ûgY[¬,üÙ¼Ì§H¼ðýbG9ßƒñð÷¾Rk^')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (455, N'Noah', N'Caruso', N'noah.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'´2PÈ`AŒ£Þ(@*L2ÕksÇ."UëúaÁMÒNyïê.±:A_£fîµãS¢|––SD¶{7géÇÓüÐîü×')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (456, N'Emma', N'Barone', N'emma.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'1·á¥Ímg‚¨¥£Òl&Êg`ÍyÃK«§''ÿy¶Õ,+.ä6,b÷Cõl«ná€¨ÚÖÑ_S,°ÃÕáã…ÚÎ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (457, N'Liam', N'Valentini', N'liam.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'ÇÖa~Ñ?äÂøæÁÆž)½¾ðÜ*Ìi–-B~0ò&•Kp` TsÉr~?F"ãÐõ…c¡üV&Ó‹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (458, N'Oliver', N'Battaglia', N'oliver.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'FíòBicA°òÊÖþ:!ÀŽ]É4)ÍWS|«ì‡])kQ×JwR0QÃ¯=í[I	ÈÉ¬<ruíF³yb_ÛW')
GO
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (459, N'Ava', N'Bianchi', N'ava.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'ûbÞ`3þ8"Ú!<V±¨Lâ˜\	Í#(»#:îó6hL”¾Œ™ÂüMr(+¦´(F„Tm ™u±ƒV	')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (46, N'Joseph', N'Ferrari', N'joseph.ferrari@example.com', N'7778889999', N'123 Pine Road', 0, N'ƒŠ§}Œ“ÕùBç½H®¨‚ zcÓp9òž
ÑÓW²p=2]4öÖx”aO‘ÉJ¬æ;B«hFô›')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (460, N'Sophia', N'Leone', N'sophia.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'^''VØ§·VˆjI°E„F8 Ùâwo1d¹Z„èa‘yœ¼> jòñrèÈãšµKÉí0LåÁfÎ’$ð,n')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (461, N'Noah', N'Romano', N'noah.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'ã¿Ï''ŸkRˆê…Jð ÅÐb«¿/xbÑ³[»V\\d…¸¬#s4—ÀdR¢Ô°ŸûÄë,<Ñõ=Åú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (462, N'Emma', N'Ricci', N'emma.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'Z..x){úá{''Šô[v"r1E}x@ë‡Œ1šñû–÷“h¾Ž‘’eÏLØîfJ|¢ñv_íE±Ë')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (463, N'Liam', N'Sorrentino', N'liam.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'ËAS„å²$þoHî¹œÍNì  $†]‘<w‹Äò{MÛydErì$~ïJ–Mªl&<7ùc›U')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (464, N'Oliver', N'De Angelis', N'oliver.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'TÛLý"Š‘of€ƒoÛUæ,ñÃ»ƒÍî¹„a½M±k×¤Ÿ
.B¯S€†hdÎÊy4…è¨h«UìÉñ1¤')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (465, N'Ava', N'Marini', N'ava.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N' eóÌ6ªÍ
;s6}ÅÊÏ¤âÎ–d2È¥7Ä,Ó"":aRüHKh‹ù]Ý>¦RmDÕÔ›kAÄ)–™ý+z')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (466, N'Sophia', N'Lombardi', N'sophia.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'RrŒw’¡ÔÙµí‰ãÅ|³÷ÈU¬|ÃWàáy[è"ë¬[q@¥·àFÖÍOR°¿7õLÔ¢:Û„dñYÉÐq;­')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (467, N'Jackson', N'De Rosa', N'jackson.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'ô^ÃÍßŸFJëGí÷šækvDÜ®ç¾!„	› ´þ]|Á‘L)Y$Ú±s´â‚«&[ÔÎÚùXnÅ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (468, N'Olivia', N'Russo', N'olivia.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'ŽZ@€kš»%f©r;¥¦:d *I”<k·RÀ9›Ž¤¸KtÍ>É
ìû†éo_‰MR)â@±­4	Ö‘')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (469, N'Noah', N'Ferrante', N'noah.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'µ^¬&u;Ô@DŠmbžöÚ\ŸT8â´ÓÝ½Ì«W“¼ƒ¿;61·k”þ\‘ü1«ùIëöi;Œ2ï5íÞè')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (47, N'Ella', N'Barbieri', N'ella.barbieri@example.com', N'5554443333', N'456 Cedar Street', 0, N'îNrÇ¥›ÎòWR€æªÓ˜âÅ’&0Œ	~“â/|°WÇz!*Ÿ
&g	¥ÂÜ«ŽºPjÌÝÜenÝLŸÌ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (470, N'Emma', N'DAmico', N'emma.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'æ"Ôglú›µCÂg˜Ô€œnítHbfèñÇ­‹ì2f¨¡e=Sv§~ž@›Šš$÷÷¼Á«íhÀ7¹V‰[Ý
ýø')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (471, N'Oliver', N'Battaglia', N'oliver.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'ÕmŽÍ€}7p³Íµ{ž!Á;$Fç)éžª¨ï±€ÔF¦¦®Ê÷HS—™bœÍvˆ]ââ¹|’S²ßè£ÇsU')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (472, N'Ava', N'Rinaldi', N'ava.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'¦cê$yL8Ù;Iê‰TçºwÄóçøJóKñÌï¸rÜ>²AŽØglÓÕã¿îqR±û¿V‰ÅT°êƒ÷1')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (473, N'Liam', N'Guerra', N'liam.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'ÀÕýðºê4…îŠCÅh¸J‚ÝÏur3wGðHŠ]s„DøŠÎz¤ž|Áa.	zv‚
£¶˜	²yÛ«Ä')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (474, N'Olivia', N'Marini', N'olivia.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'ÿ+`nƒÈ_Ù"uÈ†è\°ŒÉÎÈxG®¤,è
åöŸžüÎ¸B¤<-³ˆ{Y´Az–9*¹ILiÄÿä¬')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (475, N'Noah', N'Caruso', N'noah.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'	>ð§“r”³s.Ûk¤øU+ÚŒOë*#½/Ã²€\AÆ\jÆ?æ‰ÞTÃŽ§,‚™CMÀÛ‹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (476, N'Emma', N'Barone', N'emma.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'ö$No12öþŽ‘;€v¢50=a„µ\­? dÇ$¶c¹âEu/Ö’Sv»×Ùñ§6c8OßÜÐ¦ÒFÀü')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (477, N'Liam', N'Valentini', N'liam.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'¹Ù{ÓªÀ…‚,ÏM¬Îræ€œ¼YWZ…ò’Ÿ!ïZ#u:{ˆ® …!¡O=òG8#Ù›à
|Ã^ [§û²Ëm')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (478, N'Oliver', N'Battaglia', N'oliver.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'%ÔÁÕ0Fw¬Âk“KýÛ†Uvue,1KÐÙa¥ƒáöjù’˜ü§`æ€±€£¡[môÒÚÔoÖ?)šD3‘u')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (479, N'Ava', N'Bianchi', N'ava.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'£Ö^îIpÇu=Èˆ’„ÇI~Q—ë7÷Óæ0´.
c©)ª~âM#ØA,Ol”»+ýj¶^!¼/Nå(b­´â¢')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (48, N'David', N'Marchetti', N'david.marchetti@example.com', N'2223334444', N'789 Elm Street', 0, N'_û×«äÂÌMG{áüLøêg;9ãÚÂü=_“@œôê	Ùwüç)„½´êF˜Z™uóØKxûdu~îÖOQlø')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (480, N'Sophia', N'Leone', N'sophia.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'ñ¢¾îI4Ö·Ÿ á´Vßˆ,:üŠþÕ•ÄöEÎ°ãH6¹©àŽÛ(Z*p÷˜iˆ÷ËjSÑm¤˜rÝ-')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (481, N'Noah', N'Romano', N'noah.romano@example.com', N'5556667777', N'890 Cedar Street', 0, N'†¢;"÷““ƒNÈ¸”V1[@¹
¸p^~ Âx|¨•mv;$Ž7g-b&ƒ/Í¶iŽùHJ8Ôqü½LÀ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (482, N'Emma', N'Ricci', N'emma.ricci@example.com', N'7778889999', N'123 Pine Road', 0, N'aåÎ|ê å-ëŸÁ˜‡j‡¸Dü™ŽWpZßÇV¿Ôüu<&4mº¿K™Î­|Ï³©±âÅ½éQâ!RŸp®À')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (483, N'Liam', N'Sorrentino', N'liam.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'Ý­—ò©N¦×¿TwˆgÔÇín-![¥§Vôë9è« —&×úëJ^tã°"
|×‰ÕgCd)Yþ±RÍ0t_[')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (484, N'Oliver', N'De Angelis', N'oliver.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'ƒk½³
åo»Vc4ØÇƒR I„ÌFD•Ê~JNòøÇZ¦ýÏ(''¸%Ñ}Î¡:)ýSËCØÏªfC?R')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (485, N'Ava', N'Marini', N'ava.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'˜é‰úNM¿MÈÎpB2''çU†Ëcâu³Ûb63sì°e¢…¯++û‡/Ys[¥ô:‘KÞË3Ù°YÎ»w ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (486, N'Sophia', N'Lombardi', N'sophia.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'z"º[°pmsˆÁO ö«¦§Ad‚v~˜§€Ø¸÷fK_ð¨-—!yñ1ÉÙÙ4Ÿ½»yX{¥–2Ð[†')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (487, N'Jackson', N'De Rosa', N'jackson.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'¬þtOs³õp¼â/ÍÊ‰W?}©:áo"7.ŸÞ±ÅÊ·ÌÖý’êT¡¶&Uaÿ}Æ³³íî)ÒTæ7~aÐÁ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (488, N'Olivia', N'Russo', N'olivia.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'|M++?ÆÆË*»þ”ÍJÅ¸>/A¥Âa“¼qjËRãr5Âr² Ñ€Ûa*¯œÏy·r@1½øùŽ"FùŠ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (489, N'Noah', N'Ferrante', N'noah.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'¢qË‰ÜS÷lQI3‰f(`r‘Å°¿–!·¢é\t—n Òdö›³L€FÎš¤Uö^†Dñ#·ïÃ¸,Nkèaz')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (49, N'Aubrey', N'De Santis', N'aubrey.desantis@example.com', N'4443332222', N'321 Oak Avenue', 0, N'ð×Ã×K,3@•)j§?!¥&ËîžO2É	‡ŽB’µw °ÝaæÁˆBŠrOXÈ×ßÑo“Ü“è°¬ðÐ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (490, N'Emma', N'DAmico', N'emma.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'<·]mñ`ß&JlóCoN%’9Œ†íìŽ¾ùƒ¢…¢=TÔDŸÜ!Ñ"—x3õ}Ã$0î{P|›(ar')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (491, N'Oliver', N'Battaglia', N'oliver.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'î…`Ì,êÊvß_a–åµOc©÷SßµëâŒÍFW¶`Ì™j±Ìï\I/ToÕë^•lÑö³hÝê£V')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (492, N'Ava', N'Rinaldi', N'ava.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'°oæ’.ó#AÄ¤©R©YÈI`4Õ	|eëážäj8üÑWön;2ûq„8&µ¦žGbŸ
³4&
#ÃôÆ|×µ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (493, N'Liam', N'Guerra', N'liam.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'e%0$"ç8š®¿•­•…›té®ú‡o[8üð’¤iÐÎYîtþõ|Žz›l„
"!•Øžê» Ÿ.©Ù')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (494, N'Olivia', N'Marini', N'olivia.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'Â·àòôò;;ÆT~*ûSoÚÊ=_#ÖæD1¯*|F/(Z÷Å™_§¼ÒZ-XWoí×¥¨)NŠwð3WÔÍœ»Ú~')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (495, N'Noah', N'Caruso', N'noah.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'–rÒÛã5ÃtB‘TÝå5]öÓªj)%Ûf>—Yi¬Ž¨å`êhä]ÍbÙ³O…ùú¡ ïåÑäÔZ=¾lè¹j')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (496, N'Emma', N'Barone', N'emma.barone@example.com', N'1112223333', N'987 Elm Street', 0, N' Æÿù³FPf7­b,ðôÃÍÅà¢>„ÝgŽB[ŸR9I&_º9Ô‹ór À¸DðÓ˜d¸¯¤¦_?Ó')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (497, N'Liam', N'Valentini', N'liam.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'óœ¹ëî_ß”7Ï±óTÉ z¢¶õ-xBûòÖ£ù¹Ïà|i€¢=íA:X+¶‡*ÖºÕp,Ù^R^DvB	
	úB')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (498, N'Oliver', N'Battaglia', N'oliver.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ÈDÜAÛ„Wô˜É(VSMÄùéÙ#£kòø
"o/fRpÍY5›É0D,7ÜFª''â/g›ëGìFM/K\«')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (499, N'Ava', N'Bianchi', N'ava.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'gjü›í?ÕÅ›’»pk1°|¢É8
A^×úõ÷¶°²™ÞÌ}Í>È×0
˜~¹úñœ_úÔY‚ÅZ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (5, N'Sophia', N'Brown', N'sophia.brown@example.com', N'2223334444', N'654 Maple Lane', 0, N'9Æõ2ž•›*ðÞ°øÚËÍõA‚ôk®Õˆö+|’#ÆoôpÍe:Iöïöú‡häo&“¨¿aôùƒržƒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (50, N'Christopher', N'Guerra', N'christopher.guerra@example.com', N'5556667777', N'654 Maple Lane', 0, N'*fãGæ?n…È#XX/Ê¿qbäÛ;…SèÌu-œ¿+XWNEýhB¬øR
NóˆÉN6w6HÎZ`Y˜‹3/Ÿ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (500, N'Sophia', N'Leone', N'sophia.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'OÓX\möá\·Þ¸ ¤[ºjoQÌÈbYS^<°ÈýåÑW¥í»Î¬íÂ6¬:%‹YeÛw|a¹®™¯‹Pú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (501, N'Liam', N'Moretti', N'liam.moretti@example.com', N'4445556666', N'567 Oak Avenue', 0, N'"Äér±?õCjh_`EZY0z˜ërSßDÆóU!ì œ°”—Ó@žJÐ>2öR–
K+çðÔþ9ãú—«P«£')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (502, N'Olivia', N'Messina', N'olivia.messina@example.com', N'5556667777', N'890 Cedar Street', 0, N'
©j* tRjÓA eþSx€/RÅEx©W=]g¸­ CdñfPE²ßÏ5Tæ$“°JW"*cÆÑK5
@')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (503, N'Noah', N'Rizzo', N'noah.rizzo@example.com', N'7778889999', N'123 Pine Road', 0, N'-6l÷lN‚4SÄV-ä.zøÓÖ¶.™ë‘ÁÇo4„/÷6ˆ¤+[ð1ÝÏwR‡«ÕâíÒÐŒ.í¿è')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (504, N'Emma', N'Marini', N'emma.marini@example.com', N'5554443333', N'456 Cedar Street', 0, N'_r 
W\WþK¨	aj©J–|”9èŽí(Õèêh¢¢^‡šµgvÍ«²æ8w ¼cS)3+ÂA´èK±ôGh’')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (505, N'Sophia', N'Ferrari', N'sophia.ferrari@example.com', N'2223334444', N'789 Elm Street', 0, N'~èJ 2ÏYFýŠp†ìúDë°¶ž¼ôÝ6¸×„ìøSÿäþÚé@‹ÝäUY’“½ÞPbð­äqüìèF')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (506, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'4443332222', N'321 Oak Avenue', 0, N'³˜Â·¾vµâO:8ð"F“¥@	ó{J¾uÏ‚É}Å§ÿiÇM Xð¶:ª¸‹I£œ0ëòÜEVcK9Ç
«w')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (507, N'Ava', N'Russo', N'ava.russo@example.com', N'5556667777', N'654 Maple Lane', 0, N'¢ò³¶_¢Pv„JUq0ïr6<ÔÒX5{kcÌì×à ã^
ƒ@4Ÿ…Às!•Òˆ@2èmA¯''ó4ou8T@')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (508, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'1112223333', N'987 Elm Street', 0, N'ßKbàÊìZï§Ä.Nå®‰LUHQçîE:,ƒ×zEWÉ×k.ŒÉ>•t‹[â×©cŠtWH:XJ5ým')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (509, N'Olivia', N'DAmico', N'olivia.damico@example.com', N'4445556666', N'234 Pine Road', 0, N'ƒØ?É&¼´×ð–üä6±ÏæëZéûÁôRË·–šôZAŽçºÖ®@uÍL·ÈÍ“!—jÉ¸ò-Ò:S§Â,')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (51, N'Aaliyah', N'Pellegrini', N'aaliyah.pellegrini@example.com', N'1112223333', N'987 Elm Street', 0, N'œ~…%1E;ÉÒòÃ<×ô6Ç{Li§›r?~Ô{°áJÆùËrõÂh3×–y&4"­»B[¿Ü)™ð°OMÒ Q')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (510, N'Noah', N'Sorrentino', N'noah.sorrentino@example.com', N'6665554444', N'567 Oak Avenue', 0, N';ýPš''áy:7s£ãä›²\`uÐ8=œÐš¬àáM‹O|‘Ã™Ÿ}gãžyå2iÿó
MÒúeÏ&')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (511, N'Emma', N'Valentini', N'emma.valentini@example.com', N'5556667777', N'890 Cedar Street', 0, N'ÇX?$ÒæH\N%‡zòæÞ7VÕØŒ>±3X˜§F:å¥“Àþd“Ê]²<7‡Ì A|.¤†>$½ìÔ\k')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (512, N'Liam', N'Battaglia', N'liam.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'rÀ	¸¸˜Ó¼|¤Ê»(ÿì®—FŠé2†TOðŒ™dõ »!.CbÁ3ˆâ­fy›i^yuBÝž¥…zg/õ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (513, N'Olivia', N'Rinaldi', N'olivia.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'½½ôœ&›â/ ×Gsrû¡ãÏ€NQMZ?†ê.ûû6f ‰‹j‚¸Û¿øÏÈÑÀ‰A®.WÍÃ<Y')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (514, N'Noah', N'Guerra', N'noah.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'ðÖºøîÍþvQÐ‚	ÕŒ\âa,¤¾#z²§sâã@Ì¾£·W62Åá—:êFÛ„Å˜(º^@™èJ¹ Ì')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (515, N'Emma', N'Marini', N'emma.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'=V’îž''%¡›¬q2ßÎñ…iÕz¹FÑ$P¼^™ã
eî4þ¨fÑþñ;–°ì3ßô—êû813Ôà^ÔÜS')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (516, N'Sophia', N'Caruso', N'sophia.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'Ãyê¤_·D(TpyW)ž¼…áñSCw*QKä.TÊ‘Åg''ßÞO9¨
\Ì‘Ý0ãÎþW™Ð´§–§€iž ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (517, N'Oliver', N'Barone', N'oliver.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'^È¥½ý%Ïøý#ŸÇ£xãâÑðjû¥x›«ÜòEê$Õ>¤‹;¸æŠQ¼xëµªê¨Ï; lØ8ÊÃ$£§ŸYþ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (518, N'Ava', N'Valentini', N'ava.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'’ºdÙks`âÀ„<ãæ£Íö&ýÝ·;›''ì„%hFÞ~=ª “zRÕ–Vy‹'')Ø4¬üï`ä "D')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (519, N'Liam', N'Battaglia', N'liam.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'VŠ¹®X#Œðc˜½ö³¾oð2;_×G²Ór)W+ Ù 1ÚR!‹‹_Äjd‚¦}‘Ç¸3ÕËªãJÕÓÃÓl²')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (52, N'Gabriel', N'Martini', N'gabriel.martini@example.com', N'4445556666', N'234 Pine Road', 0, N'\`·™ÍºVd2ÿÆd:ýL#LÊøæ•!°µÍhÏ+"lÅŒn V[³~~SÉ¼(€Éç/Ëûæ$9˜½q{')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (520, N'Olivia', N'Bianchi', N'olivia.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'›¶FFr¦{öœ6U"à+õù±UDð‡ÕóQ–^<¬³¸kVG½¤s˜cðNK§Œå€82ÿ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (521, N'Noah', N'Leone', N'noah.leone@example.com', N'7778889999', N'123 Pine Road', 0, N'Þ„š²W®1íÛÙN8Wû‚DZv
ŸU3HF|áD#õË''Ø¥´''×´ðØËI#´?.°9ßô°™}<')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (522, N'Emma', N'Moretti', N'emma.moretti@example.com', N'5554443333', N'456 Cedar Street', 0, N'“Æäš¿KIb‹4ušp]m*k¾²›iª Ua0eÛ:lûË@ °Ù¨ap”Ÿ°Ã4£í(!Ù€µ5?Ç"—\Š')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (523, N'Sophia', N'Messina', N'sophia.messina@example.com', N'2223334444', N'789 Elm Street', 0, N'Ÿ''ê€aîJD"ˆÍxÒã¦Ê³ƒ–>Ñ5D=3p o®¤º°Mß±rd¿ÿZ5) òst=
ëè¦²o')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (524, N'Oliver', N'Rizzo', N'oliver.rizzo@example.com', N'4443332222', N'321 Oak Avenue', 0, N'VÜÅBwR˜¦óžëK
è‘k¿ Hèùåèi³h _kÕE°0hiW#ÿŸHÃž*ÎÝ ^³Ëœ/³éü3äÙ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (525, N'Ava', N'Marini', N'ava.marini@example.com', N'5556667777', N'654 Maple Lane', 0, N'Û‡”áÊÒT“>N½N}ðôMrV…DQ#]DØ(Ï°rÕ ^ÒY^”·Û"Ðƒþ;dT£Q­eKk¢>®¡Ýû')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (526, N'Liam', N'Ferrari', N'liam.ferrari@example.com', N'1112223333', N'987 Elm Street', 0, N'D|>á%øÝ½^·;ŽÎHâ
ó§Ñý=«EØâ‰¦•JìG’™ã"Ã C°K<\¿ÝVpt+ší›"Ù2k,Xøª,')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (527, N'Olivia', N'Bianchi', N'olivia.bianchi@example.com', N'4445556666', N'234 Pine Road', 0, N'ŸÚ5!¬Š1ºO¦Ý“ÿdËÿlð”
>Aeòšüç+|ê•@ô»ÉˆÏçÐœ}xfÀk/a´=®yò®°ø˜')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (528, N'Noah', N'Russo', N'noah.russo@example.com', N'6665554444', N'567 Oak Avenue', 0, N'_BˆšÉüÈ""C¯æWrÂ''˜Á´Ó î~Fí‰ ¢[`:;Ý"Ä5Wûö³Xs;;=#U÷Œè¡¨¢T^ïnæ‡Ëz')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (529, N'Emma', N'De Angelis', N'emma.deangelis@example.com', N'5556667777', N'890 Cedar Street', 0, N'ë—˜†:­íÝ_UäÆ»®	-OÇôÉ„sÐXbŠT¤ŠûFÛ†„l#š@(Qß $ŸH˜
sU¨²Ê‘o»F5')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (53, N'Abigail', N'Serra', N'abigail.serra@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ïOÏ#ßÙµ÷ÓÂLVÅÒŸéÕ²–;ÙÇÌµ=©£>$ÿ…^îKÍºâ²H†¨Ùz(MÌdP A.r‡Ÿ_ú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (530, N'Sophia', N'DAmico', N'sophia.damico@example.com', N'7778889999', N'123 Pine Road', 0, N'šÖËŽ2ŸySEÊOÏP íFq$r¢_Çø;¾ðïFkÈb§‰?ô}{Æ$gd’ƒÏW`aˆn¶=ºRG±tMô‹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (531, N'Oliver', N'Sorrentino', N'oliver.sorrentino@example.com', N'5554443333', N'456 Cedar Street', 0, N'n†ÔáSeÆ.ÒZ:A÷Æ‰qCJ[Âq“‹Œ:ð¤ÅúÞŸY‰¹‹~¾ü¼Ï,cÎ÷M—1{¬{¹¡÷ Ý')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (532, N'Ava', N'De Angelis', N'ava.deangelis@example.com', N'2223334444', N'789 Elm Street', 0, N'™h®
nÏß(V€vtó5Ü€÷T¨ãýß¹µsBáJŸsõ:IåŸÍ3
þÄQk²<j&ä
Ü!,pheú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (533, N'Liam', N'Marini', N'liam.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'l^1ä:]4ùô˜C°ã©DÍgÐ
€S8¼“wÚ˜6}E¼ÆÔ`‡¯¹öHXS"Ï¢“ÃK„lh8
k3%â±')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (534, N'Olivia', N'Valentini', N'olivia.valentini@example.com', N'5556667777', N'654 Maple Lane', 0, N'æk¡×ð„Ný¿-WäÆæÑŸObúÍVÛtL/-ßåe Æ
ìªÓ|5ŽÍª²¦µÖ°ËÛ…Ÿ%ù]0T/¨š”')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (535, N'Noah', N'Battaglia', N'noah.battaglia@example.com', N'1112223333', N'987 Elm Street', 0, N'—al: ôlØä’7`édÕ„ÛßÛ3{<R*kö
ÿu"Š
^V×Ò^Ð/‹}õ"­ël­^îú²±È')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (536, N'Emma', N'Rinaldi', N'emma.rinaldi@example.com', N'4445556666', N'234 Pine Road', 0, N'ã]ˆÄ×SýÖÒˆx,gå,õ¼s/‘³lL.¹¾¤³íÌ°°ó±n¸Y«_ÃíÁ¹2–£Hå…£Ys')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (537, N'Sophia', N'Guerra', N'sophia.guerra@example.com', N'6665554444', N'567 Oak Avenue', 0, N'éCïP^cN6š³´
æPèÜªj§Hû„}5ñ­*7½-ÅY¾³ía
ìÑöÈC ÷Ê÷Þ>Ø]¯ýjÎ²i')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (538, N'Oliver', N'Marini', N'oliver.marini@example.com', N'5556667777', N'890 Cedar Street', 0, N'cFS†ÊõèÂwQ£ü­8àìžiUÿq?óIíYšEuðôfD˜g!
R*Ô4…X™tT&!nâÑCoÖÖ½d«')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (539, N'Ava', N'Caruso', N'ava.caruso@example.com', N'7778889999', N'123 Pine Road', 0, N'%0Mì…®1zšC:þsqvÜÆ3ƒ''Œ¦†ïhŠ ²×ã»ä\
àžN7òC ˜[KÍS=jù« ó-tkdé©')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (54, N'Andrew', N'Bellini', N'andrew.bellini@example.com', N'5556667777', N'890 Cedar Street', 0, N'Ûf‹©ÚRX?ÁStˆHN.ÊX~Õi­^Ë(§Õ¼º¼Fù`ðmcH2ÌŠ*—8œOñ„-3Ç›Øýõ@?yLÅ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (540, N'Liam', N'Barone', N'liam.barone@example.com', N'5554443333', N'456 Cedar Street', 0, N'ÒCÑØq¶8ÞxùÑç|ÚÞ©¤ÐÆåÁõ“ÅIÎå!o+1Ãµ±Ö¸eö¼Œm¦r3.yš‚ìûìrP')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (541, N'Olivia', N'Valentini', N'olivia.valentini@example.com', N'2223334444', N'789 Elm Street', 0, N'Óy1jüRK›HB\.<N¡"N>–^ÚcÎè§¡>ÈçŽ‡þ4
[q''/&š+iô¯õqêü±_)4‹Xj,9')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (542, N'Noah', N'Battaglia', N'noah.battaglia@example.com', N'4443332222', N'321 Oak Avenue', 0, N'TºqùøËAeÈÉi¬—7¾¦y°÷
ÛYÅˆcµ)BýÝT:yús-Ÿ5êqLº¢ÈoÀ´ãâLßè3
2èr<­')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (543, N'Emma', N'Rinaldi', N'emma.rinaldi@example.com', N'5556667777', N'654 Maple Lane', 0, N'¢ý«&,’
óÍº¢Z š)MOôOÐü¡cÌÃè@uÕ×Ô¥5GêQ4CjV1ä‚xWXÀçWeÐáNŠ"')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (544, N'Sophia', N'Guerra', N'sophia.guerra@example.com', N'1112223333', N'987 Elm Street', 0, N'£²Âóø–ÈI#C4&zôLEä‹gÕ8UdªaÔ¦N®Ú¦³•‡=ö?!Ó
»{k‡‘ñ¸‘óUË
¶ÔIèÒfr')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (545, N'Oliver', N'Marini', N'oliver.marini@example.com', N'4445556666', N'234 Pine Road', 0, N'-ìzOœtÑpúÇÁ$¡†OÏ"
[Âgâ”¤n÷IÓãââÓc+…þÍ¹I•çQ¦wrï
—Bò¾\V')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (546, N'Ava', N'Caruso', N'ava.caruso@example.com', N'6665554444', N'567 Oak Avenue', 0, N'‰eçºÛñºì­,w…÷}!H‹µ.r(²=—D©SëÝ‚Rè½©''¸žùË
Œ&Ô1•’C©1%ë	øí2ý|Íû')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (547, N'Liam', N'Bianchi', N'liam.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'Z>í"±f#çÙF
	~²äCº-¦î®¯@µM¶RØòùi5ƒ#šèô¾î:%KÜ~Z|NNÂf(’a‘Àƒù')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (548, N'Olivia', N'Messina', N'olivia.messina@example.com', N'7778889999', N'123 Pine Road', 0, N'iÖßOtG1ƒ¼
O“ê•å7‰kú}=¡nñxu
þ!OE²†Ø×HöI(¡ïgë¾¡gº:8ÁM 1Øâ')
GO
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (549, N'Noah', N'Rizzo', N'noah.rizzo@example.com', N'5554443333', N'456 Cedar Street', 0, N'?ŽZëÑ”qlº Ag>YöÇ<¢|É\å³ ëmsû-»;`Ð­¾µlT–IÍac›tØ ˆœcŽŠÐ¸gå[')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (55, N'Alyssa', N'Cesari', N'alyssa.cesari@example.com', N'7778889999', N'123 Pine Road', 0, N'1¡„k²< £P³ëdXÖé;M±_ÄFËb±€_·uäÃ#ùÃ@·Ò¼±MvpI,ÝøÛîMßd 
Q¨')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (550, N'Emma', N'Marini', N'emma.marini@example.com', N'2223334444', N'789 Elm Street', 0, N'–`åªPií[¾AW€uLšÝ„>Ì)µ
A=Mi–KI$ü‡¹h~Ûn®©T­Ð½¿hÌV›ÑèÓ¬z:­')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (551, N'Sophia', N'Ferrari', N'sophia.ferrari@example.com', N'4443332222', N'321 Oak Avenue', 0, N'òo,! ?''ÊüŠ¬ýgE/ö¨/ÚþÙÝ7"=?gjÚÕ»²ƒúÀZ‹Ž>Ñ¯p4ê„›èÖt°;)ãŒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (552, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'5556667777', N'654 Maple Lane', 0, N'X0®wîž	¯©ÝxH¹8%ÂÑYÎÈñr9^•*|
¶Çæ‰žXÙý‚Â$\Îîâ³çiŸ˜û~%&')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (553, N'Ava', N'Russo', N'ava.russo@example.com', N'1112223333', N'987 Elm Street', 0, N'ã¯·È¯/"§ToŸÏgÄ¨o
lâÎ:ØQS1ÿ ?õÀûßW(p¼†4cŠÿþG\7áN7ÚóÓ12.èk\')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (554, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'4445556666', N'234 Pine Road', 0, N'ªmçâ9oºÇöOµ›Ç`¥ž}êý­ÇÓ†"ë°ósCýsÎìá]Õi-‘f€‹S}éAúÓL7Ló¥')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (555, N'Olivia', N'DAmico', N'olivia.damico@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ÀjÙ$q|óÁhiCù| Ú¸”µñ3#ê±Ð%Ô¼æçåþ¿õ!dö `†òŒ¦šÿ2ˆZ6j´ÁàµýR
<ü.')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (556, N'Noah', N'Sorrentino', N'noah.sorrentino@example.com', N'5554443333', N'890 Cedar Street', 0, N'Qù Üöâ«±ZÏ’~zô''¨Œ<]º)©\0îÏ%$–/BL«$ª	¢&pmTe2©rÒ‚4ÌIí¨')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (557, N'Emma', N'Valentini', N'emma.valentini@example.com', N'2223334444', N'321 Oak Avenue', 0, N'F}wŒú"ìÈÈ ¯î×;Ë>°]îò
¶¤-N;)26ª&"H_5Â|k2A–ƒVmwîx ÞŸVr"Áaî')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (558, N'Liam', N'Battaglia', N'liam.battaglia@example.com', N'4443332222', N'654 Maple Lane', 0, N'‘žkµÇPIë°{å_s¨¶y_‰ö¥x²nA]U:°z\‡˜·„ˆ<Ö”iPs©_^·ö±³Ò½‘ÊîA’')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (559, N'Olivia', N'Rinaldi', N'olivia.rinaldi@example.com', N'5556667777', N'987 Elm Street', 0, N'§šXzg×zÖªôÁ¤úX¢†DxÂ¶EæHÅnNÅQVt«o›þwOÝQØŽÀŸ<3P
huæÒ–0JÝ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (56, N'Julian', N'Monaco', N'julian.monaco@example.com', N'5554443333', N'456 Cedar Street', 0, N'¤Ê+ì]¬øVÊî²ùö¯À~kÂZßMƒ˜"s’[ÈP¿‚*ÄSZE9L—ƒÛ­BjôØ6’PÄiòý`')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (560, N'Noah', N'Guerra', N'noah.guerra@example.com', N'7778889999', N'234 Pine Road', 0, N'I³L<g@–‚µU™@}p7ð\äŒ´âîÓtæŠ£Ò—Ô!L3‚êáø*ƒ÷Æõƒ­Ïúõ1‘`‘guNIÝ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (561, N'Emma', N'Marini', N'emma.marini@example.com', N'4445556666', N'567 Oak Avenue', 0, N'®ƒhKôƒ5…WºËLÓSÐž÷o8BÚ
u°,÷ÅŸ·_~aHÀLB0<ËÂ"LÄ„tœ"‘¡i‡áP¯ò')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (562, N'Sophia', N'Caruso', N'sophia.caruso@example.com', N'5556667777', N'890 Cedar Street', 0, N'Nµ,f=-‡Pá¥ícÄz‹êÊ­ðÉX	!xq¸ø
oöÃq<æ)Êû¤ÍB3|dB^SRE?ß¶	«	nÐQn')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (563, N'Oliver', N'Barone', N'oliver.barone@example.com', N'1112223333', N'123 Pine Road', 0, N'L#<CÐ¨®ÊÅÖ<ToDò{Û×‰³úá‰×nÜìM¶Û@Í!	gò§ëR²þ,Ë@ÙÜ†„(Û–…æN¶ß')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (564, N'Ava', N'Valentini', N'ava.valentini@example.com', N'4443332222', N'456 Cedar Street', 0, N'Ù9íÑgp_­¡&§6ì/n©LŒÄo@ÜODY“vÊèkJ—‡¹­×Ž’›;¿¨0û§Uã·øî’‚¼&ý')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (565, N'Liam', N'Battaglia', N'liam.battaglia@example.com', N'5556667777', N'789 Elm Street', 0, N'6²˜D„d4X@#ï¥·2³º™‡+éŸ1#ÐžSL|á{‚TzwŸ‰òáJÿ­À9éÊWð±’]rÕ—„¡¬')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (566, N'Olivia', N'Bianchi', N'olivia.bianchi@example.com', N'7778889999', N'321 Oak Avenue', 0, N'ñ3'',áUç‰é<]6	~…¼÷|»yN‹ÙÒ:¤„íDŒ½~çvz†“Yiñíþo´Çœy¾Šæ:<')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (567, N'Noah', N'Russo', N'noah.russo@example.com', N'5554443333', N'654 Maple Lane', 0, N'0GcgUÃÚ2B‹ùu‰c[Xtó PÂ‚BSh÷‡Ü‚	8ï 7bcô
òê=ÞL	W»n]F;`X?äV6x')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (568, N'Emma', N'De Angelis', N'emma.deangelis@example.com', N'2223334444', N'987 Elm Street', 0, N'H·Þ×fUCÅ5Çüî$PF=ã“7`¨6ywÝ©,1­q
	!¹Ýæ5ÌÑfŒ’Æ`Aàc;º%V')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (569, N'Sophia', N'DAmico', N'sophia.damico@example.com', N'4445556666', N'234 Pine Road', 0, N'iÌgÄËœú`×¶Í‚÷þP­¡øÓG[fêÃÅuIÚ#œ udk&ÉA;ö3’ÆùyÊ˜˜õÔIî&')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (57, N'Natalie', N'Rinaldi', N'natalie.rinaldi@example.com', N'2223334444', N'789 Elm Street', 0, N'ó³îÆ!ô¿¼eš)È¯s8M’¾¢O¢»+.£j/Ys¼ŸO°(Ú9vKRƒê\‡>¼Bò
!-4P•/;')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (570, N'Oliver', N'Sorrentino', N'oliver.sorrentino@example.com', N'6665554444', N'567 Oak Avenue', 0, N'4IˆÿÐÛ€<Â:UE&ª¥••Þ=g§ÅmG¡4''¥AÎÓ¿_D—¤gôÆ6¾¨{=Š´| æ•±›„ºÏ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (571, N'Ava', N'De Angelis', N'ava.deangelis@example.com', N'5556667777', N'890 Cedar Street', 0, N'i‹`c”ºÊÇšRÒë@GÜ†Ô§z7fZãÄµê#õ~ˆ†yH/¦„G+fÉ†Ô¢ì\Hõ­mrÂÐÀî„')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (572, N'Liam', N'Marini', N'liam.marini@example.com', N'7778889999', N'123 Pine Road', 0, N'(þõ].l¸d7ž…"«ú…äÆ¼—g¬ò*±sIpôÝ÷@ö›^·ß–®Ý ËAŒa
KËfŠÀïamf¹\')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (573, N'Olivia', N'Valentini', N'olivia.valentini@example.com', N'5554443333', N'456 Cedar Street', 0, N'’9ô—dp''¢»¶f8¢,5µl°€›r—}4ñi^™Ì{8A„O»è`\ÃvcÞ½Ú8Žfã\ª×Ÿ±=')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (574, N'Noah', N'Battaglia', N'noah.battaglia@example.com', N'2223334444', N'789 Elm Street', 0, N'LHŽ
4 oyÐ±a>$
zK~iÜóÍ6ÍG7-)ú5Á?Drœ4;=áqÍ°‹î6×–''ÓŸA<[Þqåec')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (575, N'Emma', N'Rinaldi', N'emma.rinaldi@example.com', N'4443332222', N'321 Oak Avenue', 0, N'<¥†üB‚[Ù…FÎ¶b»:)\7o§Ž…ƒ<+î[—š§(°—?tU6;»-¼fúÇžSh¶,úªËT)')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (576, N'Sophia', N'Guerra', N'sophia.guerra@example.com', N'5556667777', N'654 Maple Lane', 0, N'ê‚/s¡F÷Î°7Á»åÓ…`¨ áÚÆX>8AÊ¼×¼Þ2/·e5 Û™×Èy‚NXÁ7N\£IØ5ÙP')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (577, N'Oliver', N'Marini', N'oliver.marini@example.com', N'1112223333', N'987 Elm Street', 0, N'ÆwOø/Œ`²ìÅN˜a¢u‡ŒÀ(‘Ðù
yóîû ,ˆÏe›Pˆ]ÿÍœ¢|Î»ñûAÈ‹-Ÿæª—ç–O')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (578, N'Ava', N'Caruso', N'ava.caruso@example.com', N'4445556666', N'234 Pine Road', 0, N'ìÐH°ÿIqòæ95˜Ýh3G#¬´¡*êÕnÝl>SŠ¹ÇáíÔ
—¤d†ŒS~%|»/js+³¤‹RÏÕû')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (579, N'Liam', N'Bianchi', N'liam.bianchi@example.com', N'6665554444', N'567 Oak Avenue', 0, N'û¦¿›ATß''É€¾<h-]²˜­|¿äR*DÃ­·£?Ëíjÿû€»+67dÑŸ}{èqÄÀ¥†¡”æÁQØžß')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (58, N'Levi', N'De Luca', N'levi.deluca@example.com', N'4443332222', N'321 Oak Avenue', 0, N'Ç¢àÄ{|ðKþ;ž±í 2:{á`™Á²MŠýy,5Ëö/ò£brœ1£›áÌý
¥$0,Ý¨¯*€dÀbÞº ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (580, N'Olivia', N'Messina', N'olivia.messina@example.com', N'5556667777', N'890 Cedar Street', 0, N'›(Z„¢å%±f
Øüy§ÏHçíDp+KªÖsû¯®×/üõ:@*ÕZyfzè?R3èd¶‰Ö¯+')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (581, N'Noah', N'Rizzo', N'noah.rizzo@example.com', N'7778889999', N'123 Pine Road', 0, N'
^³)!g"¿ÄÍZ^ Ö;l‘{''´< VHlTný(‘žnâV¸½ÇjXa¦ü%7X—êÂ±_,hä:·Ö')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (582, N'Emma', N'Marini', N'emma.marini@example.com', N'5554443333', N'456 Cedar Street', 0, N'ägJIö;öCuºxîs@ßÄ7^ÁØñPrþ)¿ßÒÓÐœ	d†b²iÉÿtãýíòæÖöÈ‹àÆ\kò')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (583, N'Sophia', N'Ferrari', N'sophia.ferrari@example.com', N'2223334444', N'789 Elm Street', 0, N'?EAËÔ–hFBvZ‡2ÕüË5Æ#t-–œã¤õ)G\¬oZÁ)Ü±!=]X‹ r</ùÔØ’(í®ª¨')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (584, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'4443332222', N'321 Oak Avenue', 0, N'»;Å>Ã	N¾Ìèy¾hçótËuAyìhryN[gæ|p\ÆùŸÝŠBjbÂÌÌ
°frÏv)åÙ‹ÖëI«S
ÀøW')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (585, N'Ava', N'Russo', N'ava.russo@example.com', N'5556667777', N'654 Maple Lane', 0, N'¤¨2°fégœ(þ%#F““ŽÊJ×‰”O¶	ñoÒÈCõ²ôÊ´‰nÜºåo3I”ÿ¦"±úãy]J/§EË')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (586, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'1112223333', N'987 Elm Street', 0, N'6Æ>p¾g''Àñê.kž`Á:Ú‘7×—g>¨Ÿ]J”ÇqåM…Z!;³k{tAÐÇ)8ªƒlîÌ¹ñ ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (587, N'Olivia', N'DAmico', N'olivia.damico@example.com', N'4445556666', N'234 Pine Road', 0, N'PÓæßÊ¥ [p^ÈO¡®þqfšyAª®ý½kïßišYS5WPœ6ƒm¼¹.¹òSë¤¬¨ªÑHëO%')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (588, N'Noah', N'Sorrentino', N'noah.sorrentino@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ýÀ¸Âòs—ÿQ–¹Î‘¯¤¬þ÷ú"%4°ù!Z‡Ý” Wyßø§Ó ©ÉÎ7ÞO"LÖe>ƒâñ@dŠzœñ—')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (589, N'Emma', N'Valentini', N'emma.valentini@example.com', N'5556667777', N'890 Cedar Street', 0, N'ÉR\¯Q#ÅkR¾-³)Ñù•’Ý¬v«¼¼”×xojõ6í6¯‹¢asÒ`fÃöÜzÚá¸•Ó<B±ùœ±’b(¼>=')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (59, N'Brooklyn', N'Messina', N'brooklyn.messina@example.com', N'5556667777', N'654 Maple Lane', 0, N'´çŒtÁøeq,ï·¼}E2ÆÚOV…+
M£¹ã%‚®,uS:Ü]bsÂ¦ªBëòGš t‰MÂ"f“˜›2	')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (590, N'Sophia', N'Caruso', N'sophia.caruso@example.com', N'7778889999', N'123 Pine Road', 0, N'“üGrµ Kiû:Ú€­;äA8p˜êŽñu÷Ë†Ìòþí’Ä[=n<á9ºr¬ÄËƒe3Bû¯Ÿ÷ºÙ71H')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (591, N'Oliver', N'Barone', N'oliver.barone@example.com', N'5554443333', N'456 Cedar Street', 0, N'§v7”1Õ3-„4ý¤»ñtÁæ¼UÎJoJPÎ£Œ8Ê­Z‰‚~	ª¸/²SæÜø4éWòËû>DJ°Þ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (592, N'Ava', N'Valentini', N'ava.valentini@example.com', N'2223334444', N'789 Elm Street', 0, N'î ±Â¹>æg¹x¤"4H¢]•ÏÐÑÏ~¿lœb´&Ö©Æ_ñuÖdÅQƒÜ-ád3ë¿¸º=)Þ‹n¦Ù ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (593, N'Liam', N'Battaglia', N'liam.battaglia@example.com', N'4443332222', N'321 Oak Avenue', 0, N'çíÐ\F/fí¤ã¶9’Sö°-Ÿ…±jhÌwæ\ÕÏk6K±$‹Š¥èŠrljå cÆûÓ~è×}QÃ¤]')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (594, N'Olivia', N'Rinaldi', N'olivia.rinaldi@example.com', N'5556667777', N'654 Maple Lane', 0, N'ê-é$G ´„}§¡¥þ3Õ]ªÒâËµ€]½6/÷-Àª¶’Ä
¿‰ëÑáæ!àfM{ƒÝ?*²Â ]€"6mH¾')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (595, N'Noah', N'Guerra', N'noah.guerra@example.com', N'1112223333', N'987 Elm Street', 0, N'*I#£8M]0·”ìØÿbÃF\ˆ)kÛ–ˆßnöÅ˜Dˆ˜GbÒ¹×9<h`”“-ã %’,r †Ôá€­Ø')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (596, N'Emma', N'Marini', N'emma.marini@example.com', N'4445556666', N'234 Pine Road', 0, N'À½CmËÜÆMí"¹YþZØ´Ù… dÍ•cøu…^{ ¦39H‘3FjýrTÿÕ½ µœuÂk»')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (597, N'Sophia', N'Ferrari', N'sophia.ferrari@example.com', N'6665554444', N'567 Oak Avenue', 0, N'T2%÷YÈ…™¤0
`àog¦E£uŠÇÒoËF§O2b"<§^Ä>õrÌºð/ÈÁº…ß ä:™¬Ò> ½ö')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (598, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'Ôê5;¯`Li&LÇÝ·ù‹ø…âÖ6¼â0?
E,ž‡ï}Yÿì3ÏÙc´)!l®/4©;fg#ÈK$]ÆŒ®°')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (599, N'Ava', N'Russo', N'ava.russo@example.com', N'7778889999', N'123 Pine Road', 0, N'Z¨v]Y7¦¤¦;côµ®º€)G$ñ+-²ÓÖ›8ƒÌ#D.‡çp/k¡Ý‘ìÒI$(É[gù¡CüÏ`Ó')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (6, N'Liam', N'Davis', N'liam.davis@example.com', N'4443332222', N'987 Elm Street', 0, N'$"Švm
åkÔÆ¨¿úKÁÝëh’ùï“Ë›£ô¤$?ä>T1A¿¬€¼cÔÜÏ{¦ò+Ù&Ê}ª')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (60, N'Henry', N'Guadagnino', N'henry.guadagnino@example.com', N'1112223333', N'987 Elm Street', 0, N']^zü­>~AÖä‘"±lê!>…ØõÜˆòâôÌ|Ðw''ù†kü&„ä¡{ûüÉ(4Ä¢©ÕpŠ‰â')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (600, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'5554443333', N'456 Cedar Street', 0, N'ÑMA•NÊ(PG•Yä”z:Ïbw‰å´ØUlÛø)„‰‡û=Z”¢dYš‚ûrMÏùzeBÓÆòŸ"p0É')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (601, N'Olivia', N'Messina', N'olivia.messina@example.com', N'5556667777', N'890 Cedar Street', 0, N'Ô‚!o0D3¾I$ƒ­¤ñßG‹K˜¬--aÝÇÓÓ—`/ÇÙÙ½ƒ~È»%Ÿóí)u>2')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (602, N'Noah', N'Rizzo', N'noah.rizzo@example.com', N'7778889999', N'123 Pine Road', 0, N'´9ž¾¯µ„R}báž\FFô·ŠäañørÕŽZÃ7L¥h—ÙÏ$Q¡Kž]?A1Qze%ö¿áÓ¥I½pÛÚ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (603, N'Emma', N'Marini', N'emma.marini@example.com', N'5554443333', N'456 Cedar Street', 0, N'»M).åBgòEÀ.£Q˜‚Uåö§!òJr7æÂðaL ;zÆ‹è†çuÅ€’Ö£qW‹u€¯dIí©¾Ûín')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (604, N'Sophia', N'Ferrari', N'sophia.ferrari@example.com', N'2223334444', N'789 Elm Street', 0, N'ƒŒ/ŽX½#Ú¡¬…r{ÁºäŽ8VnUY¯£º ^Aˆ¶¨Ì„íÚgÁØ|:$ÿÕx»f´EoòŒ$c‡')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (605, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'4443332222', N'321 Oak Avenue', 0, N'ÿØù‘¯*ë#í¢J23ž?.(~d¤¼È=z2´<Ù(¾až•€BKV,ôeP_•oà¼yþÎEm3Ø}0')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (606, N'Ava', N'Russo', N'ava.russo@example.com', N'5556667777', N'654 Maple Lane', 0, N'…ü¦fMpPd‘væÊ´Ìe“öË?–è‚óLÚFû;án2ºB-‘w·WÒ!â43’îå²Í"L‘áëÏÁ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (607, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'1112223333', N'987 Elm Street', 0, N'$ìHnƒJªé¹ò¾Ùje_ÿfßõv`V92;/¥“¼l;µ…’ú¸«»y¡Cûßp„&ÿî›£Œ»qÒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (608, N'Olivia', N'DAmico', N'olivia.damico@example.com', N'4445556666', N'234 Pine Road', 0, N'}î`/”A0ÌI¤l7V•Xx¢„Í—¬1ÎC`F9ïáš§ÒØ<ZT§,Io¦Âê‰Ï¸+§§?¡HCÄÒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (609, N'Noah', N'Sorrentino', N'noah.sorrentino@example.com', N'5556667777', N'567 Oak Avenue', 0, N'á/
CB‘Š~¯¯ß.ô{ÄS.¯‡Q,¢ü¢NÿkL‚­ŠÇàïötÐ ŽLD´Ý+½-‡ó<ZTÉH“T')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (61, N'Audrey', N'Ferretti', N'audrey.ferretti@example.com', N'4445556666', N'234 Pine Road', 0, N'¤öX²mL&¢ŠPxóÅG!&þ˜Ü?”Ó›gÏÂ±{¾šÀxÕJ*™ÇH+{ÖøQly­xÊ›§!IÕ5T»Mî')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (610, N'Emma', N'Valentini', N'emma.valentini@example.com', N'7778889999', N'890 Cedar Street', 0, N'¿g½AàÃ5=^Õ¬O*¼D6e3ãõp c"ô38 ÅÐñ¨8^ÙØz¬¤%÷`›§#NÁRáÏ6Å~Î')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (611, N'Sophia', N'Caruso', N'sophia.caruso@example.com', N'5554443333', N'123 Pine Road', 0, N'íÌ„Â^æšcYA°Î/dv79ª&³ÜÚªÑ$¿ìœõÐüIÒê–_rBQâsV÷Ÿ×‹yuƒE[”îÂ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (612, N'Oliver', N'Barone', N'oliver.barone@example.com', N'2223334444', N'456 Cedar Street', 0, N'%Fï2·ýöA1+À/Lôvº¥£ÛF;‰c„A¨Ô”¡–½¤V€€«ˆûÀçý·Ò„€­„X¥óÔÖòAØ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (613, N'Ava', N'Valentini', N'ava.valentini@example.com', N'4443332222', N'789 Elm Street', 0, N'†üQ„kEÕªŸŽ«uÎ”§,òñP¢ú1ÒÇÍõc­Ï¬ÈÄ,6PÎ®&!O*ö`‚‚ë3ˆÃ’³Ö')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (614, N'Liam', N'Battaglia', N'liam.battaglia@example.com', N'5556667777', N'321 Oak Avenue', 0, N'ùÎ %TõW¯ëN¥''2¶ÒId,åfCµ`:ú7Íl‡å[nqæeÖì½”7"¿µ,p&´cuÎ ØhB£t×')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (615, N'Olivia', N'Rinaldi', N'olivia.rinaldi@example.com', N'1112223333', N'654 Maple Lane', 0, N'•¢ÅÑW˜
Ý]Jò:Ÿ»Ät…ÇFQñ]Ãlª“÷N	€Gû-i,Üýg®4à,}×lTÁyÝ"˜ô"“')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (616, N'Noah', N'Guerra', N'noah.guerra@example.com', N'4445556666', N'987 Elm Street', 0, N'!îÜ	hy\O;5*ˆ	¶óPðÞkÅ|ÄâðÿÌ\œxTlÖïQ&=H»''£Ð“ÕŠˆß	 ‹<YÂÇfxœœ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (617, N'Emma', N'Marini', N'emma.marini@example.com', N'6665554444', N'234 Pine Road', 0, N'®zk¥YOÕÒOWZÜ|u»7Ñ+Ýp¹F}4wj¶êÕ¨¸Ÿä‹ÃÃtýÝ¤Ž°¥ÐóO_éÁUÚ¸Èðm')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (618, N'Sophia', N'Ferrari', N'sophia.ferrari@example.com', N'5556667777', N'567 Oak Avenue', 0, N'‹ýF“¨ÏJûkúrÚ„¤N27&Ú(«dy`I6OÜ¿?}uƒž¬¾–H!cC·0cJ1+±=[ÌÿE')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (619, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'7778889999', N'890 Cedar Street', 0, N'*áøýÉ(ÆX;Öe\Â¡ÅÂèw''¥¶âÝÇ¸gUUm]#*x4_b¨ZcùÍ¼?ÜŒ…—*¼¶÷võ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (62, N'Ryan', N'Parisi', N'ryan.parisi@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ú}
úZ)š ²ài sÉ6¤/qÀ®Ò0d—»‡1]*H½;†ÍµSŠm&§Ö1| ô|WÊØ S!i„rÚ[¦')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (620, N'Ava', N'Russo', N'ava.russo@example.com', N'5554443333', N'123 Pine Road', 0, N'PÐù9ÀXÊÕ6Uî‘bQd9NX0íGùNÓ~b;h¡ºÏé¯æ Âb9}Ÿ‘‡¢S\¯rNó¸sÔÈe#í0')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (621, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'5556667777', N'456 Cedar Street', 0, N'ýIç,b,>›VÉ¯ÚK†àšWùNãP+—–¿£NVÍ¯#v*''†à–O ”\P8`ºydÂú1°,\"ñç')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (622, N'Olivia', N'Messina', N'olivia.messina@example.com', N'2223334444', N'789 Elm Street', 0, N'Æ•½‹KD%ˆ¢
"ý=­âg&ahžˆ´¢$uš©Öú]Ž}.Õh¿
²È¸ú–`V„Ó·'' €Àd')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (623, N'Noah', N'Rizzo', N'noah.rizzo@example.com', N'4443332222', N'321 Oak Avenue', 0, N'
Ñcj•þT„ìä.šXòà<Te²žžò™~˜ùÈJ§<<â~‚å¼]r†~´)‡^:íoÜZ·¸&Ÿ#ûñ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (624, N'Emma', N'Marini', N'emma.marini@example.com', N'5556667777', N'654 Maple Lane', 0, N'C
|½©˜®·êÈË F\ˆªl7/wÓÜñ» ùÌ<ÒSL ÊpÕT®(
X…þ5å¶i/(ˆ~@è')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (625, N'Sophia', N'Ferrari', N'sophia.ferrari@example.com', N'1112223333', N'987 Elm Street', 0, N'dnZµæ	ÔúXç<£÷ñ¸‰×rB,°¤øNîÛ§2-·Þ…aÅl5z¹BM†cZ7doxæ—ÃÄÕqÜÍ?ñ®Ä')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (626, N'Oliver', N'Bianchi', N'oliver.bianchi@example.com', N'4445556666', N'234 Pine Road', 0, N'.Ô%%ì!Ûóžƒ>4ùI„ÌÅ^Æ²0R± Ïð\µ‘ô²¶Ú ©Z?¥ÙnÃá0YHY Ÿ=—ß“ŒÃ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (627, N'Ava', N'Russo', N'ava.russo@example.com', N'6665554444', N'567 Oak Avenue', 0, N'‘OÎh÷4DŸâÂ7aìôÕ¸.¶÷²£Šj¬Ýï+ÂÔ`¹STÈÈv/bPÊ*ñçèúàtÒÄ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (628, N'Liam', N'De Angelis', N'liam.deangelis@example.com', N'5554443333', N'890 Cedar Street', 0, N'“Áo°{8É×m;úÁ/šÙR½…ré‡ˆØåðñÛÞî4E\àÃ/?·
žÏÁr§¥_ÁcêëÄÛ—Çß}kX{')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (629, N'Olivia', N'DAmico', N'olivia.damico@example.com', N'7778889999', N'123 Pine Road', 0, N'@MW²{ƒ~›^ÝÂºrM‚[´Å”´[ÓÀ5Â ;}&!»Èáˆ¹U‡bó]Äm‡\jçž§›íð!MgëíXÒ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (63, N'Claire', N'Santoro', N'claire.santoro@example.com', N'5556667777', N'890 Cedar Street', 0, N'É‘Ýá¦GS¸,Ú~<Ðï`ÇtE¢—„¤d+œ™àcƒ?Ž²™q›cO‚6;í¿ù#i>—lÊ6Å ÊC~NJgÛ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (630, N'Noah', N'Sorrentino', N'noah.sorrentino@example.com', N'5556667777', N'456 Cedar Street', 0, N'ÏÙ’Q(<y£².óÇÙsÂò®ùNs( "ÑÊÎ8Ox–·6­Ú—<>l¢šüTŽt^âWPÇ²ãÅ==±å‰nû† ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (631, N'Vu', N'Anh', N'vuvietanh@gmail.com', N'123456789', N'Hanoi, Vietnam', 1, N'$2a$10$Y9/wMuf8Z4/EYQbp9iIuremT0Y1jJJZojGmO/A6QUp9OCyVLDgZpi')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (64, N'John', N'Gatti', N'john.gatti@example.com', N'7778889999', N'123 Pine Road', 0, N'Ó±ÏÒ‰á‚dµ}6Ð"êÄý‘ïM~bHjÅâª°Î…ú`<X÷èÕ÷Fp.z	¶Ìn ¾ª­…OàBJ
ù.^')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (65, N'Skylar', N'Valenti', N'skylar.valenti@example.com', N'5554443333', N'456 Cedar Street', 0, N's–Ó]€‘*È²ªç
™Eø¶Ij®ú$¨Ý½Ö’mp±ZþèçŸ ¶›¹6ƒ}Èvê††×´®ˆq‘'' j')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (66, N'Julian', N'Ferraro', N'julian.ferraro@example.com', N'2223334444', N'789 Elm Street', 0, N'ú-ú3ûú‡´®Ç10Ÿ*ç™hn;aQfË*ôf6¸¥$ºSå7ö¢ºð	íN²Ü5l}+T4mÂ¼!2²är')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (67, N'Samantha', N'Silvestri', N'samantha.silvestri@example.com', N'4443332222', N'321 Oak Avenue', 0, N'Z!Á6s‹¢”áGyb?}°ÓKâžóïéeù¤.­¡“&LŠ¾LýGn‚¦{ý7nV½`È¨ÜêÌD”tïB')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (68, N'Nathan', N'Palumbo', N'nathan.palumbo@example.com', N'5556667777', N'654 Maple Lane', 0, N' ŸØs˜v©®K,ñ@CP6	1»#cdÝçJžMùñmy
M¯•šÕ
š÷c‹³›ÒA#e¥#fN„Küž{')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (69, N'Hannah', N'Monteleone', N'hannah.monteleone@example.com', N'1112223333', N'987 Elm Street', 0, N'	¦DÅsš ýœ†n]ŒJgAI¢uå56¤á¶õO…{ÄNî6´ŒrÀ}õ©gž™[äŒt‹üüo')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (7, N'Ava', N'Miller', N'ava.miller@example.com', N'5556667777', N'234 Pine Road', 0, N'§×…y
ì·šJ;ÍQ—0çh—ø:$$©¸A`í¥ÞôfÕ¨Œåæ+çàé‘-’á¶O—±Ñ:P–îÀ—G
îwd')
GO
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (70, N'Jonathan', N'Marchetti', N'jonathan.marchetti@example.com', N'4445556666', N'234 Pine Road', 0, N'¸°#ÙcœÿÚ¹„W<ÆÉ—hÒôZa‡ûž‚§:pUM‚E)G¾í9WJsüíL!}x¯R[®‹g0Ó(')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (71, N'Lily', N'Palmieri', N'lily.palmieri@example.com', N'6665554444', N'567 Oak Avenue', 0, N'pÁYoU>ËÍž#èDÕ‡„–p+ì§­ÇB¦€ãÖÅÅ­íÄùkšumØ.ÎBŒ&Ì„Ù‰ç:øÊ àÇ{Ùç''Ž‰^')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (72, N'Wyatt', N'Colombo', N'wyatt.colombo@example.com', N'5556667777', N'890 Cedar Street', 0, N'«†o¿®(í–àæŒ`è…QOÿgˆÂŒD†2HMl#g”)#Cs@žFUI
 Báó8½)¯rƒHfaÑ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (73, N'Addison', N'Bianco', N'addison.bianco@example.com', N'7778889999', N'123 Pine Road', 0, N'¦ñaÍ,N—š5PéAÎ@ë4°?#¼â•(Ú5ÿÆ¡6ÏÁ/´€¾š‡àûzvƒ2è*ªF‚t”‚G´')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (74, N'Christopher', N'De Angelis', N'christopher.deangelis@example.com', N'5554443333', N'456 Cedar Street', 0, N'•§åü\ÃßoœMþ3lf''ö#ÄX.Ë»•Lqì¬êÃ±áoœgNÅ‹:•Oú™zZpw;„ˆds°LµÌ-LD')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (75, N'Sofia', N'Vitale', N'sofia.vitale@example.com', N'2223334444', N'789 Elm Street', 0, N'ÜÁsÒdŠµ÷¡2Gi*ÁUï ²Ús[×‡ýS5 ‰$¬|ˆ‡
Á4`ñê‡ÔÚ˜Ä"(¬¯oÙ\@g¾ˆÏxÑ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (76, N'Grayson', N'Caruso', N'grayson.caruso@example.com', N'4443332222', N'321 Oak Avenue', 0, N'bæ(Çô²¸Ö^®aP1Y½ cpxOvp•1ø…¬ÀäuÄ£ñdîLÐxx¢ È®]¶HûV@ÛŽÏm=^')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (77, N'Arianna', N'De Santis', N'arianna.desantis@example.com', N'5556667777', N'654 Maple Lane', 0, N'›äQFYe#š[=iEé«“÷"âêì#0šB>¹þÕlŠ o.Æà©{ª !E,N;Šs×RT
”¡Òýb;¸')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (78, N'Joshua', N'Rizzo', N'joshua.rizzo@example.com', N'1112223333', N'987 Elm Street', 0, N'õá|8ÖvÔßµú6’ÉhT³¦<^›ßBž]¬õaÒóž×U¤%h“4®6ô¤TBÉ z
;€ªg%5;¤þ~}Ê')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (79, N'Victoria', N'Donati', N'victoria.donati@example.com', N'4445556666', N'234 Pine Road', 0, N'z¦¶’jÁñ¾]ÊhøÇÏßÇPÙ«{Ô™YµÆ‘_ÆŒÙ†TÍ‚`ˆDaH•@zé{óð»H£·ºc¤1ñ½')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (8, N'William', N'Wilson', N'william.wilson@example.com', N'1112223333', N'567 Oak Avenue', 0, N'!š«k,÷8Ùópá—ÎQ¾B®`•à×/¤•’†\-Þ]/§.ŠÃtË¥T&æÐí92OÖÞ]¢dÇôI^Ý“')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (80, N'Henry', N'Giordano', N'henry.giordano@example.com', N'6665554444', N'567 Oak Avenue', 0, N'¤ë‹
WµñŸÐ¡‰ID4Ý²ÚI‚‘‡ZqHUËoôgÀƒüp¨øƒV4!øÝ‡:`)Ù®áÀäÌ=vtÎb96Þ&')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (81, N'Layla', N'Rossi', N'layla.rossi@example.com', N'5556667777', N'890 Cedar Street', 0, N'ùÄ]íA÷Ÿ¸èòK}8—íMÐì¹–•KM‡ìž:Åùb˜uFöT
%ñ—¤è®üê2”æv
°´žzv~l{ÕŠr?')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (82, N'James', N'Ferri', N'james.ferri@example.com', N'7778889999', N'123 Pine Road', 0, N'æò•º˜	v.+©{pÓÚ¨íÆ)5GârV¾ù¾ŒB”ùJý‡BüÓÝ¤-öh²‰±·äæQ’§ æ{SÖAÅ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (83, N'Elizabeth', N'Benedetti', N'elizabeth.benedetti@example.com', N'5554443333', N'456 Cedar Street', 0, N'´~¼ýJ¤šÆ¡É§°ñ÷‹ª¶–Û¢,
<"^È~ ï¯ª,v}Ü”By¸Û	CÎ£„ Òc—›<¶¾2ì')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (84, N'Benjamin', N'Marino', N'benjamin.marino@example.com', N'2223334444', N'789 Elm Street', 0, N'´Ã"¥tä‰Iâµ:3œ™6~0©^.`È
éÝ’“›ùö…47Ï7tbÚÛ][6RÿF²‚ÎÜŠâts<–Þh')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (85, N'Savannah', N'Ricci', N'savannah.ricci@example.com', N'4443332222', N'321 Oak Avenue', 0, N'¤<¯KÒºà5Å
ð;ŽªvµÚ}rz/Š»Y”Ÿ/µåŠžZ$¼¬[P€G{³ùÑRàFÔ©SøvSC')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (86, N'Caleb', N'Lombardi', N'caleb.lombardi@example.com', N'5556667777', N'654 Maple Lane', 0, N'•X€Ó8¼V&¿þPa¾8ó X›­ÍnoS;RÀØ‰8œb´@V²rìY€ÆM¶a''±Fd™9Ê„Vï¥×Ú')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (87, N'Lillian', N'De Rosa', N'lillian.derosa@example.com', N'1112223333', N'987 Elm Street', 0, N'ÐªÝ4ÅÌ…Èºêd¡ñßß­yÁt©1	æÖ²év…2ŒÐ£éžSaÅãÿóÉ?Ú_’<…¤?í¡-w÷Gœ“r’	U')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (88, N'Samuel', N'Russo', N'samuel.russo@example.com', N'4445556666', N'234 Pine Road', 0, N'ÙŽíkNzšvÄ>—Ì4Ú€¸,>û¥âÙ®²ÖùÛ
FžÄ¿0«¥D‰E,ÊÈB†æ˜§Lº[ÆÆ+~³îÇ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (89, N'Gabriella', N'Ferrante', N'gabriella.ferrante@example.com', N'6665554444', N'567 Oak Avenue', 0, N'0„nN¨Iµ¡<J(…ŽNå”w[qß¢f.E,J¥“]×ýJƒïA"xègñU$‰¶‚Œ*Ëè¥í%¦úS')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (9, N'Isabella', N'Moore', N'isabella.moore@example.com', N'4445556666', N'890 Cedar Street', 0, N'&âaã :\€
,Hùiry6vè«FMsÚP±ÈÓYíK¬^æ`¿ãîš“b­BÊ<š§“«Op{=þ¤Ø›dúà ¹')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (90, N'Daniel', N'DAmico', N'daniel.damico@example.com', N'5556667777', N'890 Cedar Street', 0, N'NÊQÀüƒY—ñ‡«T€Ml"ßlQ˜s‘šn}Í™PÁ&‹á
>½†oÒ1%³–Ô_ÇR¬"ŠÄY)¦')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (91, N'Sofia', N'Battaglia', N'sofia.battaglia@example.com', N'7778889999', N'123 Pine Road', 0, N'†1(ý&PZ
DÀìç‡øã†Í*I_ª¡÷ÕøÅVp$Ì€o-TÞ9

Ð´›.ð,‘©î¨YßÀ˜®—ôQ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (92, N'Joseph', N'Rinaldi', N'joseph.rinaldi@example.com', N'5554443333', N'456 Cedar Street', 0, N'CÕWÏHµ{}úè -XBÒÝë°,ŸÌÅiû8p™DB°öt×`ü''—v½ký˜±Óón[ÛZÙ·åœ')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (93, N'Amelia', N'Guerra', N'amelia.guerra@example.com', N'2223334444', N'789 Elm Street', 0, N'rilî è''{q#>næ°åôÚám«®6‚“ZrÛ´‰r"fí/¯¤õà¯ E
Ó{È¢ŒƒŒÃ‰?-i/')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (94, N'Michael', N'Marini', N'michael.marini@example.com', N'4443332222', N'321 Oak Avenue', 0, N'|‡O¹™g•ÝSÄƒ‘„¤òd[Ñ:ÚÃºî1VÎr™êIo—LâfÅm¥ÅB_?ÁºU‰E£w?Ê½EECR6')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (95, N'Emily', N'Caruso', N'emily.caruso@example.com', N'5556667777', N'654 Maple Lane', 0, N'aÝfÄ&2ÛØh—­îy d§ÇwQ‹â~3ëœ?q°''©¥Íµ
És”Õ j¼H…*·½äêL]Éz7˜/')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (96, N'Daniel', N'Barone', N'daniel.barone@example.com', N'1112223333', N'987 Elm Street', 0, N'ªµ.zÐyàqÎÞCj!UñM@2pV° Ë&ã–©ÝSËi”­ºÎ.¶Þêƒ0cè_ÕàÎE øâÍ%/°Ä#')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (97, N'Scarlett', N'Valentini', N'scarlett.valentini@example.com', N'4445556666', N'234 Pine Road', 0, N'±•ô½N®â­Ü'',êh1)''ó“DN)ô5§ëFñŽM&VÙ»H2Ë§¢_g’6Î\Y—x‚)ŠÂà„ož')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (98, N'Mason', N'Battaglia', N'mason.battaglia@example.com', N'6665554444', N'567 Oak Avenue', 0, N'ÂzsB‘ r,*þšT_²Y.m¿8D˜)|ñ³IiGëT5ç]“5Ì ­NÍ&ÝçüS‘’rãèêt•¬“5Å')
INSERT [dbo].[Users] ([ID], [FirstName], [LastName], [Email], [Phone], [Address], [IsAdmin], [Password]) VALUES (99, N'Victoria', N'Bianchi', N'victoria.bianchi@example.com', N'5556667777', N'890 Cedar Street', 0, N'y©•d™MêdUÒZ5‘''Ô iG6¯#
ZGq‰Þ®™ïX|¼¼ãF´¢-N›(C/¬•Zâ¥h™ÚJÂÃÕ
ì«')
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
ALTER TABLE [dbo].[Reservation] ADD  DEFAULT ((0.00)) FOR [TotalPrice]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [IsAdmin]
GO
ALTER TABLE [dbo].[Hotel]  WITH CHECK ADD  CONSTRAINT [FK_CategoryHotel] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Category] ([CategoryId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Hotel] CHECK CONSTRAINT [FK_CategoryHotel]
GO
ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD  CONSTRAINT [FK_UsersReservation] FOREIGN KEY([UsersId])
REFERENCES [dbo].[Users] ([UsersId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [FK_UsersReservation]
GO
ALTER TABLE [dbo].[ReservationStatusEvents]  WITH CHECK ADD  CONSTRAINT [FK_ReservationRSE] FOREIGN KEY([ReservationId])
REFERENCES [dbo].[Reservation] ([ReservationId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ReservationStatusEvents] CHECK CONSTRAINT [FK_ReservationRSE]
GO
ALTER TABLE [dbo].[ReservationStatusEvents]  WITH CHECK ADD  CONSTRAINT [FK_RSCRSE] FOREIGN KEY([RSId])
REFERENCES [dbo].[ReservationStatus] ([RSId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ReservationStatusEvents] CHECK CONSTRAINT [FK_RSCRSE]
GO
ALTER TABLE [dbo].[Room]  WITH CHECK ADD  CONSTRAINT [FK_HotelRoom] FOREIGN KEY([HotelId])
REFERENCES [dbo].[Hotel] ([HotelId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Room] CHECK CONSTRAINT [FK_HotelRoom]
GO
ALTER TABLE [dbo].[Room]  WITH CHECK ADD  CONSTRAINT [FK_RoomTypeRoom] FOREIGN KEY([RoomTypeId])
REFERENCES [dbo].[RoomType] ([RoomTypeId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Room] CHECK CONSTRAINT [FK_RoomTypeRoom]
GO
ALTER TABLE [dbo].[RoomReserved]  WITH CHECK ADD  CONSTRAINT [FK_ReservationRoomReserved] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservation] ([ReservationId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RoomReserved] CHECK CONSTRAINT [FK_ReservationRoomReserved]
GO
ALTER TABLE [dbo].[RoomReserved]  WITH CHECK ADD  CONSTRAINT [FK_RoomRoomReserved] FOREIGN KEY([RoomId])
REFERENCES [dbo].[Room] ([RoomId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RoomReserved] CHECK CONSTRAINT [FK_RoomRoomReserved]
GO
USE [master]
GO
ALTER DATABASE [BookingHotel] SET  READ_WRITE 
GO
