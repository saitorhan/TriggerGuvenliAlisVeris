-- ENGELLİ MARKETLER
CREATE TABLE [dbo].[BlockedMarkets](
[Id] [int] NOT NULL
)
 
-- SİSTEM AYARLARI
CREATE TABLE [dbo].[ServerSettings](
[TagName] [nvarchar](20) NOT NULL,
[Value] [nvarchar](max) NULL
)
 
insert into [dbo].[ServerSettings]([TagName], [Value]) values('MAXPRICE', 20000)
 
-- ALIŞ VERİŞ LİSTESİ
CREATE TABLE [dbo].[Shoppings](
[Id] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
[MarketId] [int] NOT NULL,
[Price] [decimal](7, 2) NOT NULL,
[UserId] [int] NOT NULL)
 
-- KULLANICI LİSTESİ
CREATE TABLE [dbo].[Users](
[Id] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
[FullName] [nvarchar](150) NOT NULL,
[Email] [nvarchar](100) NOT NULL
)

CREATE TRIGGER [dbo].[tr_CheckShoppings]
ON [dbo].[Shoppings]
INSTEAD OF INSERT
AS
BEGIN
declare @userId int
declare @marketId int
declare @price decimal(7,2)
declare @maxPrice decimal(7,2)
declare @mailAdres nvarchar(100)
declare @control bit
 
set @control = 0
 
select top 1 @userId = UserId, @marketId = MarketId, @price = Price from inserted -- kayıt edilmeye çalışılan değerleri al
select @maxPrice = convert(decimal(7,2), [Value]) from [dbo].[ServerSettings] where [TagName] = 'MAXPRICE' -- sistemin izin verdiği max değeri tablodan çek
if @price >= @maxPrice -- harcama değeri izin aralığı dışında ise
begin
select @mailAdres = [Email] from [dbo].[Users] where Id = @userId
-- mail gönderme proceduru
EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'Sql Banka Simile',
@recipients = @mailAdres,
@body = 'Hesabınızdan limit üzerinde alış veriş yapılmaya çalışılmıştır. Güvenlik politikamız gereği onayınız alınıncaya kadar işlem iptal edilmiştir.',
@subject = 'Hesap şüpheli hareketi' ;
set @control = 1 -- Hataya düştü ise kontrol parametresini 1 ayarla
end
 
IF EXISTS(SELECT * FROM [dbo].[BlockedMarkets] WHERE Id = @marketId)
begin
select @mailAdres = [Email] from [dbo].[Users] where Id = @userId
EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'Sql Banka Simile',
@recipients = @mailAdres,
@body = 'Hesabınızdan sistemimizde enegelli bir market üzerinden alış veriş girişiminde bulunulmuştur. Güvenlik politikamız gereği onayınız alınıncaya kadar işlem iptal edilmiştir.',
@subject = 'Hesap şüpheli hareketi' ;
set @control = 1 -- Hataya düştü ise kontrol parametresini 1 ayarla
end
 
if @control = 0 -- kontrol parametresi 0 ise hataya düşmemiştir, kaydı insert et
begin
insert into [dbo].[Shoppings]([MarketId], [Price], [UserId]) select [MarketId], [Price], [UserId] from inserted
end
 
END