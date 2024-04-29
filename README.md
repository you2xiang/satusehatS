# FHIR Server For Satu Sehat 

**A.Satu Sehat implementation of the FHIR standard.** 

Standar ini dibuat oleh Health Level Seven International (HL7), yaitu sebuah organisasi standar pelayanan kesehatan (healthcare standards organization). Situs terkait:
```bash
https://www.hl7.org/fhir/
```
<hr>

**1. Memperkenalkan Konteks FHIR.** 

**1.1 Maven Users HAPI FHIR** 

Untuk menggunakan HAPI dalam aplikasi, minimal Anda perlu menyertakan inti HAPI-FHIR JAR hapi-fhir-base-[version].jar, serta setidaknya satu "struktur" JAR.

Struktur JAR berisi kelas dengan definisi sumber daya dan tipe data untuk versi FHIR tertentu.

Jika Anda menggunakan Maven, contoh berikut menunjukkan dependensi ditambahkan untuk menyertakan struktur R4.
```xml
<dependencies>
    <dependency>
        <groupId>ca.uhn.hapi.fhir</groupId>
        <artifactId>hapi-fhir-structures-r4</artifactId>
        <version>${project.version}</version>
    </dependency>
</dependencies>
 ```
 Perhatikan bahwa jika Anda ingin melakukan validasi, Anda mungkin juga ingin menyertakan JAR "validation resources", yang berisi chemas, profiles dan artifacts  lain yang digunakan oleh validator untuk versi tertentu.

```xml
<dependencies>
    <dependency>
        <groupId>ca.uhn.hapi.fhir</groupId>
        <artifactId>hapi-fhir-validation-resources-R4</artifactId>
        <version>${project.version}</version>
    </dependency>
</dependencies>
 ```
**1.2 Working with Resources.** 

Setiap jenis resources yang ditentukan oleh FHIR memiliki kelas terkait, yang berisi sejumlah "getters dan setters" untuk properti resources tersebut.

HAPI mencoba mempermudah pengisian objek, dengan menyediakan banyak metode kemudahan. Misalnya, resouce Patient memiliki properti "dikeluarkan" yang bertipe "instan" FHIR (waktu sistem dengan presisi detik atau milidetik). Ada metode untuk menggunakan tipe data FHIR yang sebenarnya, tetapi juga metode praktis yang menggunakan tipe Java bawaan.

Spesifikasi FHIR mendefinisikan sejumlah ValueSet "tertutup", seperti yang digunakan untuk "Patient.gender" . Kumpulan nilai ini harus kosong, atau diisi dengan nilai yang diambil dari daftar nilai yang diperbolehkan yang ditentukan oleh FHIR. HAPI menyediakan Enum khusus yang aman untuk membantu menangani bidang ini.

```java

Patient patient = new Patient();

// You can set this code using a String if you want. Note that
// for "closed" valuesets (such as the one used for Patient.gender)
// you must use one of the strings defined by the FHIR specification.
// You must not define your own.

patient.setGender(AdministrativeGender.fromCode("MALE");

 ```
*Note: Bisa di lihat di resourceMapper masing-masing resource di code

**1.3 Introducing the FHIR Context**

 Instance FhirContext dikhususkan untuk versi spesifikasi FHIR tertentu, jadi disarankan agar Anda menggunakan salah satu metode pabrik yang menunjukkan versi FHIR yang ingin Anda dukung dalam aplikasi, seperti yang ditunjukkan dalam cuplikan berikut:

```java
// Alternately, create a context for R4
FhirContext ctxR4 = FhirContext.forR4();
```

Repositori yang dipakai dalam aplikasi ini adalah model FHIR® R4. Model terdiri dari struct untuk setiap resource dan tipe data. Structnya cocok untuk JSON encoding/decoding.

**1.4 Parsers and Serializers**

Contoh Parser ini kemudian dapat digunakan untuk mengurai pesan. Perhatikan bahwa dapat menggunakan konteks untuk membuat parser sebanyak yang inginkan.

```java
Patient patient = new Patient();
patient.addIdentifier().setSystem("http://example.com/fictitious-mrns").setValue("MRN001");
patient.addName()
      .setUse(HumanName.NameUse.OFFICIAL)
      .setFamily("Tester")
      .addGiven("John")
      .addGiven("Q");

String encoded = ctxR4.newJsonParser().setPrettyPrint(true).encodeResourceToString(patient);
System.out.println(encoded);
```
```java
 // The following is an example Patient resource
String msgString = "<Patient xmlns=\"http://hl7.org/fhir\">"
      + "<text><status value=\"generated\" /><div xmlns=\"http://www.w3.org/1999/xhtml\">John Cardinal</div></text>"
      + "<identifier><system value=\"http://orionhealth.com/mrn\" /><value value=\"PRP1660\" /></identifier>"
      + "<name><use value=\"official\" /><family value=\"Cardinal\" /><given value=\"John\" /></name>"
      + "<gender><coding><system value=\"http://hl7.org/fhir/v3/AdministrativeGender\" /><code value=\"M\" /></coding></gender>"
      + "<address><use value=\"home\" /><line value=\"2222 Home Street\" /></address><active value=\"true\" />"
      + "</Patient>";

// The hapi context object is used to create a new XML parser
// instance. The parser can then be used to parse (or unmarshall) the
// string message into a Patient object
Patient patient = ctxR4.parseResource(Patient.class, msgString);

// The patient object has accessor methods to retrieve all of the
// data which has been parsed into the instance.
String patientId = patient.getIdentifier().get(0).getValue();
String familyName = patient.getName().get(0).getFamily();
AdministrativeGender gender = patient.getGender();

System.out.println(patientId); // PRP1660
System.out.println(familyName); // Cardinal
System.out.println(gender.toCode()); // male

```
<hr>

**B. Satu Sehat Rest APIs.** 

```java
Contoh penambahan :

    //Encounter
	@PostExchange("/Encounter")
	public String addEncounter(
		@RequestBody String encounter,
		@RequestHeader(Constant.MT_ENTITY_CODE) String entityCode);

	@PutExchange("/Encounter/{id}")
	public String updateEncounter(
		@PathVariable("id") String id,
		@RequestBody String encounter,
		@RequestHeader(Constant.MT_ENTITY_CODE) String entityCode);

	@GetExchange("/Encounter/{id}")
	public String getEncounterById(
		@PathVariable("id") String id,
		@RequestHeader(Constant.MT_ENTITY_CODE) String entityCode);

Note: Untuk penambahan Api Satu sehat dapat di "./client/satusehat/SatuSehatBaseProxy.java"

```

**B. Satu Sehat Flow** 

Dalam penyusunan resource baru resource - resource yang saling berhubungan di tempatkan di dalam satu folder yang sama.

contohnya sebagai berikut :

```bash
condition
 > model
   >>ConditionDto.java
 > ConditonController.java
 > ConditionMapper.java
 > ConditionService.java
 > ConditionServiceImpl.java
```

```bash
Note : Setiap jenis resources yang ditentukan oleh FHIR® R4 tidak bisa di gunakan untuk response, maka dibutuhkan pembuatan model balikkan sesuai response resource yang di butuhkan.
```


**C. Satu Sehat Implemantasi kafka**

**1.1 Maven Users KAFKA** 

Jika Anda menggunakan Maven, contoh berikut menunjukkan dependensi ditambahkan untuk menyertakan struktur Kafka.

```xml
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
 ```
**1.2 Configuring Topics** 

Dalam menambahkan "Topic" di kafka dapat di tambahkan di : 

```bash
"./confic/KafkaConfig.java"
```
Contohnya sebagai berikut :

```java
@Bean
	NewTopic encounterPostTopic() {
		return TopicBuilder.name("encounter-post")
				.partitions(2)
				.replicas(2)
				.build();
	}

	@Bean
	NewTopic conditionPostTopic() {
		return TopicBuilder.name("condition-post")
				.partitions(2)
				.replicas(2)
				.build();
	}
```

Kemudian langkah selanjutnya dengan membuat "Consumer" sesuai resource yang ingin di buat sebagai contohnya pada "CondisionConsumer.java"

```java
//contoh pengaplikasian topic sesuai dengan topic yang telah di buat

@KafkaListener(id = "condition", topics = { "condition-post" }, containerFactory = "listenerFactory")
	public void onMessage(ConsumerRecord<String, String> consumerRecord) throws Exception {

		log.info("Consumer Record: {}", consumerRecord);
// menambahkan code sesuai kebutuhan 
}

```