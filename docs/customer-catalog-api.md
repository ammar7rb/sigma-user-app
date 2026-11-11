# مسارات كتالوج العميل غير الموجودة على الإنتاج

شاشات الأجهزة الطبية و«اشترِ الآن وادفع لاحقًا» في تطبيق العميل تستدعي هذه المسارات كما هي. على `bahaa` فرع `production` (`99693c0d520c` في 11 نوفمبر 2026) وفرع `codex/issues-20261111` المساران موجودان للويب فقط (`/medical-devices` و`/credit-requests/{product}`) ومن دون نسخة `api/v1`. التطبيق لا يختلق منتجات ولا يسجل نجاحًا محليًا: استجابة 404 أو 405 تظهر للمستخدم كنص «المسار غير موجود على خادم الموقع بعد».

لإخفاء القائمتين من التطبيق: `--dart-define=SIGMA_UNRELEASED_CATALOGS=false`.

## الأجهزة الطبية

`GET /api/v1/medical-devices?guest_id=&limit=&offset=`

```json
{
  "total_size": 1,
  "devices": [
    {
      "id": 1,
      "name": "جهاز",
      "price": 500,
      "report_price": 35,
      "device_condition": "new",
      "origin_country": "EG",
      "description": "",
      "images": [],
      "purchase_unlocked": false
    }
  ]
}
```

`device_condition` هو `new` أو `used`. `purchase_unlocked` يصبح true فقط للعميل الذي سدد ثمن تقرير هذا الجهاز.

`GET /api/v1/medical-devices/{id}` يعيد نفس الحقول داخل `device` أو في الجذر.

`POST /api/v1/medical-devices/{id}/report-payment` بهيئة `{"request_key":"<uuid>"}` يخصم ثمن التقرير من محفظة المشتريات. 200 عند النجاح، 402 أو 409 مع `message` عند نقص الرصيد. لا يُسترد ثمن التقرير.

`POST /api/v1/medical-devices/{id}/purchase-request` من دون جسم. 200 و`message` = `تم استلام طلبكم وسيتم التواصل معكم في أقرب وقت` فقط إذا كان التقرير مسددًا، وإلا 409. ملف التقرير (pdf/doc/docx) يصل على تذكرة الدعم القائمة.

## الائتمان

`GET /api/v1/credit-products?guest_id=&limit=&offset=`

```json
{"products": [{"id": 1, "name": "منتج", "unit_price": 100, "thumbnail": null}]}
```

منتجات الإدارة المعلّمة للشراء الآجل فقط.

`POST /api/v1/credit-requests/{productId}` بهيئة `{"message":""}` الاختيارية. 200 مع `message`. لا يضيف المنتج إلى السلة. الطلب المكرر لنفس المنتج يرجع رسالة أن هناك طلبًا مفتوحًا.

## مرفقات الرسائل

رد العميل `POST /api/v1/customer/support-ticket/reply/{id}` ما زال يقبل `image[]` من نوع jpeg/png/jpg/gif/webp فقط. إرسال pdf أو doc من التطبيق سيُرفض إلى أن يوسّع الموقع قاعدة `image.*`.
