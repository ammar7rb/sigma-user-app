# كتالوج العميل كما في مسودة الموقع

المصدر: [bahaa PR #2](https://github.com/ammar7rb/bahaa/pull/2) فرع `cursor/sigma-fixes-20261111-e21d` عند `f487078`. المسارات دي **مش على** GitHub `production` لحد ما المسودة تندمج وتتنشر. التطبيق يستدعيها كما هي، ولو رجع 404 يعرض أن المسار غير منشور ولا يسجل نجاحًا محليًا.

المصادقة: `Authorization: Bearer` على المسارات المعلّمة `auth:api`.

## الأجهزة الطبية

`GET /api/v1/medical-devices`

رد Laravel paginator، عشرون عنصرًا في الصفحة. الأجهزة داخل `data`، وكل عنصر هو سجل `company_medical_devices`: `id`, `name`, `price`, `report_price`, `device_condition` (`new` أو `used`), `origin_country`, `description`, `specifications`, `images`, `is_published`, `sort_order`.

`GET /api/v1/medical-devices/{id}`

```json
{
  "device": {},
  "report_purchase": null,
  "can_request_purchase": false,
  "purchase_message": "تم استلام طلبكم وسيتم التواصل معكم في أقرب وقت."
}
```

`can_request_purchase` يبقى false إلى أن يكون لسداد التقرير `report_sent_at`.

`POST /api/v1/medical-devices/{id}/report-payment` مع `auth:api`

```json
{ "report_price": 35 }
```

`report_price` لازم يطابق سعر التقرير الحالي لثلاث خانات. الرد `201` و`{ "purchase": {} }`. تكرار الدفع لنفس الجهاز يعيد سجل السداد الحالي. نقص الرصيد أو اختلاف السعر يرجع 422 و`errors.medical_report`.

`POST /api/v1/medical-devices/{id}/purchase-request` مع `auth:api` ومن غير جسم.

`200`:

```json
{
  "message": "تم استلام طلبكم وسيتم التواصل معكم في أقرب وقت.",
  "purchase": {}
}
```

لو التقرير لسه ما اتبعتش: 422 و`errors.medical_report` = `سيظهر طلب الشراء بعد تأكيد الدفع وإرسال التقرير الفني.`

## الائتمان

`GET /api/v1/credit-products`

Paginator. المنتجات داخل `data`. منتجات الإدارة المنشورة ذات `is_credit_listing`. الحقول المستخدمة: `id`, `name`, `unit_price`, `thumbnail_full_url`.

`POST /api/v1/credit-products/{id}/request` مع `auth:api`

```json
{ "message": "اختياري حتى 189 حرفًا" }
```

`201`:

```json
{
  "message": "تم استلام طلب الائتمان رقم CR-… وسنتواصل معك.",
  "request": {}
}
```

طلب مفتوح لنفس المنتج: `409` و`لديك طلب مفتوح لهذا المنتج بالفعل.` الزر ليس إضافة إلى السلة.

## رد الدعم

`POST /api/v1/customer/support-ticket/reply/{id}`

`message` نص حتى 5000 حرف، أو ملفات في `image[]` بحد 10. الأنواع: jpeg, png, jpg, gif, webp, pdf, doc, docx. الحد 6000 كيلوبايت للملف. الرد `200` و`Support ticket reply sent.`

## ما زال غير موجود في مسودة الموقع

- صور الأجهزة الطبية: الـ JSON يرجع `images` كمسارات تخزين، و`image_url` غير مضاف للنموذج، فلا يوجد رابط عام يعرضه التطبيق.
- إنشاء تذكرة جديدة `POST /api/v1/customer/support-ticket/create` ما زال يمرّر كل المرفقات على رافع الصور ويحوّلها webp. pdf وdoc وdocx مقبولان في الرد فقط.
- ترقيم صفحات الأجهزة والائتمان يستخدم `?page=` الافتراضي لـ Laravel، من غير `guest_id` أو فلاتر إضافية.
