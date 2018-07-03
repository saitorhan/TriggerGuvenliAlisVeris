# SQL Server Trigger İle Güvenli Alış Veriş
Bu çalışmamızda sql server üzerinde trigger özelliğini kullanarak güvenli alış veriş sistemini simile etmeye çalışacağız.

NOT: Mail gönderebilmek için Sql Server üzerinde “Management > Database Mail” özelliğinin ayarlanmış ve aktifleştirilmiş olması gerekmektedir.

Senaryomuz şu şekilde olacak:

Sistem ayarlarında izin verilen max güvenli alış veriş miktarı kaydı bulunacak. Diğer bir tabloda da sistemin şüpheli bulduğu ve engellediği marketlerin listesi bulunacak.

Sistemin alış veriş tablosuna bir alış veriş kaydı geldiğinde sipariş tutarı izin verilen max. tutardan fazla ise veya alış veriş yapılan market şüpheli marketler listesinde ise kullanıcıya bir bilgi maili atılacak ve işlem iptal edilecek.
