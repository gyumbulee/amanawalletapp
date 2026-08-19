$body = @{
    login = "knowledgevistanet@gmail.com"
    password = "123456qw"
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri "http://127.0.0.1:8000/api/v1/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body

$response | ConvertTo-Json -Depth 5

16|F6wMfTiYNBPJ4g5TG1QZ6s8jhVDf6LmCzybasxn7341157ae

curl.exe -X POST "http://127.0.0.1:8000/api/v1/airtime/purchase" `
  -H "Content-Type: application/json" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 37|qVwGVEsYKa8r4hn0QLj3N4K4BATHlop5vjYplk5Yc55b22ee" `
  -d '{\"network\":\"mtn\",\"phone\":\"08011111111\",\"amount\":1000}'

curl.exe -X POST "http://127.0.0.1:8000/api/v1/airtime/purchase" `
  -H "Content-Type: application/json" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 38|oRHwSlBQ9jK5zoMDoqNlZwXDxQMD2KiOy9FDXaun6c0992d2" `
  -d '{\"network\":\"mtn\",\"phone\":\"08011111111\",\"amount\":100,\"pin\":\"8810\"}'


  curl.exe -X POST "http://127.0.0.1:8000/api/v1/auth/register" `
  -H "Content-Type: application/json" `
  -H "Accept: application/json" `
  -d '{\"first_name\":\"Tunde\",\"last_name\":\"Bello\",\"email\":\"tunde2@example.com\",\"phone\":\"08077778888\",\"password\":\"password123\",\"password_confirmation\":\"password123\",\"bvn\":\"12345678901\"}'

curl.exe -X POST "http://127.0.0.1:8000/api/v1/auth/register" `
  -H "Content-Type: application/json" `
  -H "Accept: application/json" `
  -d '{\"first_name\":\"Referred\",\"last_name\":\"User\",\"email\":\"referred@example.com\",\"phone\":\"08099998888\",\"password\":\"password123\",\"password_confirmation\":\"password123\",\"bvn\":\"12345678901\",\"referral_code\":\"S9P82AS1\"}'

curl.exe -X POST "http://127.0.0.1:8000/api/v1/webhooks/flutterwave" `
  -H "Content-Type: application/json" `
  -H "verif-hash: my-secret-hash" `
  -d '{\"event\":\"charge.completed\",\"data\":{\"status\":\"successful\",\"payment_type\":\"bank_transfer\",\"amount\":1500,\"tx_ref\":\"TEST-REF-REFERRAL\",\"flw_ref\":\"FLW-REF-REFERRAL-001\",\"customer\":{\"email\":\"referred@example.com\"}}}'

curl.exe -X GET "http://127.0.0.1:8000/api/v1/referrals/summary" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 13|typGqzNaItJidXrDWpygxPBUKnZphtdKxaB909nw01b22970"

curl.exe -X GET "http://127.0.0.1:8000/api/v1/referrals/summary" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 14|aWtNXRAXeHzepEqlJ0ikjaYAnpaufjfeuJUpNDoA93af94cb"

curl.exe -X GET "http://127.0.0.1:8000/api/v1/notifications" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 14|aWtNXRAXeHzepEqlJ0ikjaYAnpaufjfeuJUpNDoA93af94cb"


curl.exe -X GET "http://127.0.0.1:8000/api/v1/notifications/unread-count" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 14|aWtNXRAXeHzepEqlJ0ikjaYAnpaufjfeuJUpNDoA93af94cb"

curl.exe -X POST "http://127.0.0.1:8000/api/v1/notifications/d825f689-fdcb-4de3-9f9b-b9b22ce9b70a/read" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 14|aWtNXRAXeHzepEqlJ0ikjaYAnpaufjfeuJUpNDoA93af94cb"

curl.exe -X POST "http://127.0.0.1:8000/api/v1/airtime/purchase" `
  -H "Content-Type: application/json" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 14|aWtNXRAXeHzepEqlJ0ikjaYAnpaufjfeuJUpNDoA93af94cb" `
  -d '{\"network\":\"mtn\",\"phone\":\"08011112222\",\"amount\":500}'


  $headers = @{
    Accept = "application/json"
    Authorization = "Bearer 16|F6wMfTiYNBPJ4g5TG1QZ6s8jhVDf6LmCzybasxn7341157ae"
}

$body = @{
    network = "mtn"
    phone = "08011111111"
    amount = 1000
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://127.0.0.1:8000/api/v1/airtime/purchase" `
    -Method POST `
    -Headers $headers `
    -ContentType "application/json" `
    -Body $body


curl.exe -X GET "http://127.0.0.1:8000/api/v1/reports/daily-sales" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 15|CFnSofxThm7bgSY55i2t7eS1nJNEDdedur7ygt4j47302868"

curl.exe -X GET "http://127.0.0.1:8000/api/v1/reports/revenue" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 15|CFnSofxThm7bgSY55i2t7eS1nJNEDdedur7ygt4j47302868"

  curl.exe -X GET "http://127.0.0.1:8000/api/v1/reports/service-sales" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 15|CFnSofxThm7bgSY55i2t7eS1nJNEDdedur7ygt4j47302868"

curl.exe -X GET "http://127.0.0.1:8000/api/v1/reports/user-growth" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 15|CFnSofxThm7bgSY55i2t7eS1nJNEDdedur7ygt4j47302868"

curl.exe -X GET "http://127.0.0.1:8000/api/v1/reports/export?type=service-sales&format=csv" `
  -H "Authorization: Bearer 15|CFnSofxThm7bgSY55i2t7eS1nJNEDdedur7ygt4j47302868" `
  -o service-sales2.csv

  curl.exe -X GET "http://127.0.0.1:8000/api/v1/reports/export?type=service-sales&format=pdf" `
  -H "Authorization: Bearer 15|CFnSofxThm7bgSY55i2t7eS1nJNEDdedur7ygt4j47302868" `
  -o service-sales2.pdf

  16|F6wMfTiYNBPJ4g5TG1QZ6s8jhVDf6LmCzybasxn7341157ae

  curl.exe -X POST "http://127.0.0.1:8000/api/v1/profile/set-pin" `
  -H "Content-Type: application/json" `
  -H "Accept: application/json" `
  -H "Authorization: Bearer 16|F6wMfTiYNBPJ4g5TG1QZ6s8jhVDf6LmCzybasxn7341157ae" `
  -d '{\"pin\":\"1234\",\"pin_confirmation\":\"1234\"}'