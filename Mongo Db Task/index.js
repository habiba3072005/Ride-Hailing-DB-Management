const { MongoClient } = require("mongodb");
const readline = require("readline");

const uri = "mongodb://localhost:27017";
const client = new MongoClient(uri);

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function ask(question) {
  return new Promise((resolve) => rl.question(question, resolve));
}


const tripsData = [
  // ── completed (1–60) ──
  { trip_id: 1,  request_id: 1,  driver: { driver_id: 31, name: "Samy Wahba" },      vehicle: { vehicle_id: 1,  model: "Toyota Corolla",    plate: "ABC-101" }, start_time: new Date("2023-05-01T08:05:00"), end_time: new Date("2023-05-01T08:40:00"), status: "completed",   final_fare: 47.00 },
  { trip_id: 2,  request_id: 2,  driver: { driver_id: 32, name: "Heba Sobhy" },       vehicle: { vehicle_id: 2,  model: "Hyundai Elantra",   plate: "DEF-202" }, start_time: new Date("2023-05-01T09:06:00"), end_time: new Date("2023-05-01T09:35:00"), status: "completed",   final_fare: 39.00 },
  { trip_id: 3,  request_id: 3,  driver: { driver_id: 33, name: "Adel Gaber" },       vehicle: { vehicle_id: 3,  model: "Kia Sportage",      plate: "GHI-303" }, start_time: new Date("2023-05-02T10:07:00"), end_time: new Date("2023-05-02T10:55:00"), status: "completed",   final_fare: 78.00 },
  { trip_id: 4,  request_id: 4,  driver: { driver_id: 34, name: "Noha Helmy" },       vehicle: { vehicle_id: 4,  model: "Nissan Sunny",      plate: "JKL-404" }, start_time: new Date("2023-05-02T11:08:00"), end_time: new Date("2023-05-02T12:10:00"), status: "completed",   final_fare: 92.00 },
  { trip_id: 5,  request_id: 5,  driver: { driver_id: 35, name: "Fady Eskander" },    vehicle: { vehicle_id: 5,  model: "Chevrolet Aveo",    plate: "MNO-505" }, start_time: new Date("2023-05-03T08:36:00"), end_time: new Date("2023-05-03T09:15:00"), status: "completed",   final_fare: 61.00 },
  { trip_id: 6,  request_id: 6,  driver: { driver_id: 36, name: "Ramzy Attia" },      vehicle: { vehicle_id: 6,  model: "Toyota Yaris",      plate: "PQR-606" }, start_time: new Date("2023-05-03T09:37:00"), end_time: new Date("2023-05-03T10:05:00"), status: "completed",   final_fare: 36.00 },
  { trip_id: 7,  request_id: 7,  driver: { driver_id: 37, name: "Samir Ghoneim" },    vehicle: { vehicle_id: 7,  model: "Mitsubishi Lancer", plate: "STU-707" }, start_time: new Date("2023-05-04T10:36:00"), end_time: new Date("2023-05-04T11:10:00"), status: "completed",   final_fare: 51.00 },
  { trip_id: 8,  request_id: 8,  driver: { driver_id: 38, name: "Hossam Fahmy" },     vehicle: { vehicle_id: 8,  model: "Honda Civic",       plate: "VWX-808" }, start_time: new Date("2023-05-04T11:35:00"), end_time: new Date("2023-05-04T12:15:00"), status: "completed",   final_fare: 56.00 },
  { trip_id: 9,  request_id: 9,  driver: { driver_id: 39, name: "Ashraf Morsy" },     vehicle: { vehicle_id: 9,  model: "Toyota Corolla",    plate: "YZA-909" }, start_time: new Date("2023-05-05T08:07:00"), end_time: new Date("2023-05-05T09:00:00"), status: "completed",   final_fare: 82.00 },
  { trip_id: 10, request_id: 10, driver: { driver_id: 40, name: "Emad Rizk" },        vehicle: { vehicle_id: 10, model: "Hyundai Elantra",   plate: "BCD-110" }, start_time: new Date("2023-05-05T09:06:00"), end_time: new Date("2023-05-05T09:45:00"), status: "completed",   final_fare: 43.00 },
  { trip_id: 11, request_id: 11, driver: { driver_id: 41, name: "Walid Aziz" },       vehicle: { vehicle_id: 11, model: "Kia Sportage",      plate: "EFG-211" }, start_time: new Date("2023-05-06T10:05:00"), end_time: new Date("2023-05-06T10:48:00"), status: "completed",   final_fare: 49.00 },
  { trip_id: 12, request_id: 12, driver: { driver_id: 42, name: "Nabil Kamel" },      vehicle: { vehicle_id: 12, model: "Nissan Sunny",      plate: "HIJ-312" }, start_time: new Date("2023-05-06T11:07:00"), end_time: new Date("2023-05-06T11:35:00"), status: "completed",   final_fare: 31.00 },
  { trip_id: 13, request_id: 13, driver: { driver_id: 43, name: "Ihab Nassar" },      vehicle: { vehicle_id: 13, model: "Chevrolet Aveo",    plate: "KLM-413" }, start_time: new Date("2023-05-07T08:38:00"), end_time: new Date("2023-05-07T09:20:00"), status: "completed",   final_fare: 67.00 },
  { trip_id: 14, request_id: 14, driver: { driver_id: 44, name: "Gamal Farag" },      vehicle: { vehicle_id: 14, model: "Toyota Yaris",      plate: "NOP-514" }, start_time: new Date("2023-05-07T09:36:00"), end_time: new Date("2023-05-07T10:20:00"), status: "completed",   final_fare: 72.00 },
  { trip_id: 15, request_id: 15, driver: { driver_id: 45, name: "Magdy Hanna" },      vehicle: { vehicle_id: 15, model: "Honda Civic",       plate: "QRS-615" }, start_time: new Date("2023-05-08T10:36:00"), end_time: new Date("2023-05-08T11:10:00"), status: "completed",   final_fare: 41.00 },
  { trip_id: 16, request_id: 16, driver: { driver_id: 47, name: "Alaa Dabbour" },     vehicle: { vehicle_id: 17, model: "Hyundai Elantra",   plate: "WXY-817" }, start_time: new Date("2023-05-08T11:38:00"), end_time: new Date("2023-05-08T12:25:00"), status: "completed",   final_fare: 64.00 },
  { trip_id: 17, request_id: 17, driver: { driver_id: 48, name: "Mostafa Elewa" },    vehicle: { vehicle_id: 18, model: "Kia Sportage",      plate: "ZAB-918" }, start_time: new Date("2023-05-09T08:06:00"), end_time: new Date("2023-05-09T08:50:00"), status: "completed",   final_fare: 48.00 },
  { trip_id: 18, request_id: 18, driver: { driver_id: 50, name: "Fawzy Metwally" },   vehicle: { vehicle_id: 20, model: "Honda Civic",       plate: "FGH-220" }, start_time: new Date("2023-05-09T09:08:00"), end_time: new Date("2023-05-09T10:15:00"), status: "completed",   final_fare: 97.00 },
  { trip_id: 19, request_id: 19, driver: { driver_id: 31, name: "Samy Wahba" },       vehicle: { vehicle_id: 1,  model: "Toyota Corolla",    plate: "ABC-101" }, start_time: new Date("2023-05-10T10:07:00"), end_time: new Date("2023-05-10T10:55:00"), status: "completed",   final_fare: 53.00 },
  { trip_id: 20, request_id: 20, driver: { driver_id: 32, name: "Heba Sobhy" },       vehicle: { vehicle_id: 2,  model: "Hyundai Elantra",   plate: "DEF-202" }, start_time: new Date("2023-05-10T11:05:00"), end_time: new Date("2023-05-10T11:40:00"), status: "completed",   final_fare: 29.00 },
  { trip_id: 21, request_id: 21, driver: { driver_id: 33, name: "Adel Gaber" },       vehicle: { vehicle_id: 3,  model: "Kia Sportage",      plate: "GHI-303" }, start_time: new Date("2023-05-11T08:06:00"), end_time: new Date("2023-05-11T08:50:00"), status: "completed",   final_fare: 45.00 },
  { trip_id: 22, request_id: 22, driver: { driver_id: 34, name: "Noha Helmy" },       vehicle: { vehicle_id: 4,  model: "Nissan Sunny",      plate: "JKL-404" }, start_time: new Date("2023-05-11T09:07:00"), end_time: new Date("2023-05-11T09:55:00"), status: "completed",   final_fare: 58.00 },
  { trip_id: 23, request_id: 23, driver: { driver_id: 35, name: "Fady Eskander" },    vehicle: { vehicle_id: 5,  model: "Chevrolet Aveo",    plate: "MNO-505" }, start_time: new Date("2023-05-12T10:06:00"), end_time: new Date("2023-05-12T10:40:00"), status: "completed",   final_fare: 34.00 },
  { trip_id: 24, request_id: 24, driver: { driver_id: 36, name: "Ramzy Attia" },      vehicle: { vehicle_id: 6,  model: "Toyota Yaris",      plate: "PQR-606" }, start_time: new Date("2023-05-12T11:09:00"), end_time: new Date("2023-05-12T12:05:00"), status: "completed",   final_fare: 89.00 },
  { trip_id: 25, request_id: 25, driver: { driver_id: 37, name: "Samir Ghoneim" },    vehicle: { vehicle_id: 7,  model: "Mitsubishi Lancer", plate: "STU-707" }, start_time: new Date("2023-05-13T08:37:00"), end_time: new Date("2023-05-13T09:25:00"), status: "completed",   final_fare: 74.00 },
  { trip_id: 26, request_id: 26, driver: { driver_id: 38, name: "Hossam Fahmy" },     vehicle: { vehicle_id: 8,  model: "Honda Civic",       plate: "VWX-808" }, start_time: new Date("2023-05-13T09:37:00"), end_time: new Date("2023-05-13T10:20:00"), status: "completed",   final_fare: 55.00 },
  { trip_id: 27, request_id: 27, driver: { driver_id: 39, name: "Ashraf Morsy" },     vehicle: { vehicle_id: 9,  model: "Toyota Corolla",    plate: "YZA-909" }, start_time: new Date("2023-05-14T10:36:00"), end_time: new Date("2023-05-14T11:15:00"), status: "completed",   final_fare: 50.00 },
  { trip_id: 28, request_id: 28, driver: { driver_id: 40, name: "Emad Rizk" },        vehicle: { vehicle_id: 10, model: "Hyundai Elantra",   plate: "BCD-110" }, start_time: new Date("2023-05-14T11:38:00"), end_time: new Date("2023-05-14T12:25:00"), status: "completed",   final_fare: 59.00 },
  { trip_id: 29, request_id: 29, driver: { driver_id: 41, name: "Walid Aziz" },       vehicle: { vehicle_id: 11, model: "Kia Sportage",      plate: "EFG-211" }, start_time: new Date("2023-05-15T08:06:00"), end_time: new Date("2023-05-15T08:45:00"), status: "completed",   final_fare: 37.00 },
  { trip_id: 30, request_id: 30, driver: { driver_id: 42, name: "Nabil Kamel" },      vehicle: { vehicle_id: 12, model: "Nissan Sunny",      plate: "HIJ-312" }, start_time: new Date("2023-05-15T09:07:00"), end_time: new Date("2023-05-15T09:50:00"), status: "completed",   final_fare: 43.00 },
  { trip_id: 31, request_id: 31, driver: { driver_id: 43, name: "Ihab Nassar" },      vehicle: { vehicle_id: 13, model: "Chevrolet Aveo",    plate: "KLM-413" }, start_time: new Date("2023-05-16T10:07:00"), end_time: new Date("2023-05-16T10:55:00"), status: "completed",   final_fare: 67.00 },
  { trip_id: 32, request_id: 32, driver: { driver_id: 44, name: "Gamal Farag" },      vehicle: { vehicle_id: 14, model: "Toyota Yaris",      plate: "NOP-514" }, start_time: new Date("2023-05-16T11:06:00"), end_time: new Date("2023-05-16T11:45:00"), status: "completed",   final_fare: 40.00 },
  { trip_id: 33, request_id: 33, driver: { driver_id: 45, name: "Magdy Hanna" },      vehicle: { vehicle_id: 15, model: "Honda Civic",       plate: "QRS-615" }, start_time: new Date("2023-05-17T08:39:00"), end_time: new Date("2023-05-17T09:35:00"), status: "completed",   final_fare: 93.00 },
  { trip_id: 34, request_id: 34, driver: { driver_id: 47, name: "Alaa Dabbour" },     vehicle: { vehicle_id: 17, model: "Hyundai Elantra",   plate: "WXY-817" }, start_time: new Date("2023-05-17T09:36:00"), end_time: new Date("2023-05-17T10:10:00"), status: "completed",   final_fare: 32.00 },
  { trip_id: 35, request_id: 35, driver: { driver_id: 48, name: "Mostafa Elewa" },    vehicle: { vehicle_id: 18, model: "Kia Sportage",      plate: "ZAB-918" }, start_time: new Date("2023-05-18T10:37:00"), end_time: new Date("2023-05-18T11:15:00"), status: "completed",   final_fare: 38.00 },
  { trip_id: 36, request_id: 36, driver: { driver_id: 50, name: "Fawzy Metwally" },   vehicle: { vehicle_id: 20, model: "Honda Civic",       plate: "FGH-220" }, start_time: new Date("2023-05-18T11:37:00"), end_time: new Date("2023-05-18T12:20:00"), status: "completed",   final_fare: 47.00 },
  { trip_id: 37, request_id: 37, driver: { driver_id: 31, name: "Samy Wahba" },       vehicle: { vehicle_id: 1,  model: "Toyota Corolla",    plate: "ABC-101" }, start_time: new Date("2023-05-19T08:08:00"), end_time: new Date("2023-05-19T09:00:00"), status: "completed",   final_fare: 70.00 },
  { trip_id: 38, request_id: 38, driver: { driver_id: 32, name: "Heba Sobhy" },       vehicle: { vehicle_id: 2,  model: "Hyundai Elantra",   plate: "DEF-202" }, start_time: new Date("2023-05-19T09:09:00"), end_time: new Date("2023-05-19T10:05:00"), status: "completed",   final_fare: 85.00 },
  { trip_id: 39, request_id: 39, driver: { driver_id: 33, name: "Adel Gaber" },       vehicle: { vehicle_id: 3,  model: "Kia Sportage",      plate: "GHI-303" }, start_time: new Date("2023-05-20T10:07:00"), end_time: new Date("2023-05-20T10:55:00"), status: "completed",   final_fare: 54.00 },
  { trip_id: 40, request_id: 40, driver: { driver_id: 34, name: "Noha Helmy" },       vehicle: { vehicle_id: 4,  model: "Nissan Sunny",      plate: "JKL-404" }, start_time: new Date("2023-05-20T11:06:00"), end_time: new Date("2023-05-20T11:48:00"), status: "completed",   final_fare: 42.00 },
  { trip_id: 41, request_id: 41, driver: { driver_id: 35, name: "Fady Eskander" },    vehicle: { vehicle_id: 5,  model: "Chevrolet Aveo",    plate: "MNO-505" }, start_time: new Date("2023-05-21T08:06:00"), end_time: new Date("2023-05-21T08:52:00"), status: "completed",   final_fare: 51.00 },
  { trip_id: 42, request_id: 42, driver: { driver_id: 36, name: "Ramzy Attia" },      vehicle: { vehicle_id: 6,  model: "Toyota Yaris",      plate: "PQR-606" }, start_time: new Date("2023-05-21T09:07:00"), end_time: new Date("2023-05-21T09:50:00"), status: "completed",   final_fare: 44.00 },
  { trip_id: 43, request_id: 43, driver: { driver_id: 37, name: "Samir Ghoneim" },    vehicle: { vehicle_id: 7,  model: "Mitsubishi Lancer", plate: "STU-707" }, start_time: new Date("2023-05-22T10:08:00"), end_time: new Date("2023-05-22T11:00:00"), status: "completed",   final_fare: 78.00 },
  { trip_id: 44, request_id: 44, driver: { driver_id: 38, name: "Hossam Fahmy" },     vehicle: { vehicle_id: 8,  model: "Honda Civic",       plate: "VWX-808" }, start_time: new Date("2023-05-22T11:07:00"), end_time: new Date("2023-05-22T11:58:00"), status: "completed",   final_fare: 57.00 },
  { trip_id: 45, request_id: 45, driver: { driver_id: 39, name: "Ashraf Morsy" },     vehicle: { vehicle_id: 9,  model: "Toyota Corolla",    plate: "YZA-909" }, start_time: new Date("2023-05-23T08:37:00"), end_time: new Date("2023-05-23T09:20:00"), status: "completed",   final_fare: 63.00 },
  { trip_id: 46, request_id: 46, driver: { driver_id: 40, name: "Emad Rizk" },        vehicle: { vehicle_id: 10, model: "Hyundai Elantra",   plate: "BCD-110" }, start_time: new Date("2023-05-23T09:37:00"), end_time: new Date("2023-05-23T10:12:00"), status: "completed",   final_fare: 35.00 },
  { trip_id: 47, request_id: 47, driver: { driver_id: 41, name: "Walid Aziz" },       vehicle: { vehicle_id: 11, model: "Kia Sportage",      plate: "EFG-211" }, start_time: new Date("2023-05-24T10:36:00"), end_time: new Date("2023-05-24T11:18:00"), status: "completed",   final_fare: 49.00 },
  { trip_id: 48, request_id: 48, driver: { driver_id: 42, name: "Nabil Kamel" },      vehicle: { vehicle_id: 12, model: "Nissan Sunny",      plate: "HIJ-312" }, start_time: new Date("2023-05-24T11:39:00"), end_time: new Date("2023-05-24T12:35:00"), status: "completed",   final_fare: 88.00 },
  { trip_id: 49, request_id: 49, driver: { driver_id: 43, name: "Ihab Nassar" },      vehicle: { vehicle_id: 13, model: "Chevrolet Aveo",    plate: "KLM-413" }, start_time: new Date("2023-05-25T08:07:00"), end_time: new Date("2023-05-25T08:55:00"), status: "completed",   final_fare: 56.00 },
  { trip_id: 50, request_id: 50, driver: { driver_id: 44, name: "Gamal Farag" },      vehicle: { vehicle_id: 14, model: "Toyota Yaris",      plate: "NOP-514" }, start_time: new Date("2023-05-25T09:08:00"), end_time: new Date("2023-05-25T10:00:00"), status: "completed",   final_fare: 72.00 },
  { trip_id: 51, request_id: 51, driver: { driver_id: 45, name: "Magdy Hanna" },      vehicle: { vehicle_id: 15, model: "Honda Civic",       plate: "QRS-615" }, start_time: new Date("2023-05-26T10:07:00"), end_time: new Date("2023-05-26T10:50:00"), status: "completed",   final_fare: 60.00 },
  { trip_id: 52, request_id: 52, driver: { driver_id: 47, name: "Alaa Dabbour" },     vehicle: { vehicle_id: 17, model: "Hyundai Elantra",   plate: "WXY-817" }, start_time: new Date("2023-05-26T11:06:00"), end_time: new Date("2023-05-26T11:42:00"), status: "completed",   final_fare: 36.00 },
  { trip_id: 53, request_id: 53, driver: { driver_id: 48, name: "Mostafa Elewa" },    vehicle: { vehicle_id: 18, model: "Kia Sportage",      plate: "ZAB-918" }, start_time: new Date("2023-05-27T08:36:00"), end_time: new Date("2023-05-27T09:15:00"), status: "completed",   final_fare: 41.00 },
  { trip_id: 54, request_id: 54, driver: { driver_id: 50, name: "Fawzy Metwally" },   vehicle: { vehicle_id: 20, model: "Honda Civic",       plate: "FGH-220" }, start_time: new Date("2023-05-27T09:39:00"), end_time: new Date("2023-05-27T10:35:00"), status: "completed",   final_fare: 84.00 },
  { trip_id: 55, request_id: 55, driver: { driver_id: 31, name: "Samy Wahba" },       vehicle: { vehicle_id: 1,  model: "Toyota Corolla",    plate: "ABC-101" }, start_time: new Date("2023-05-28T10:39:00"), end_time: new Date("2023-05-28T11:45:00"), status: "completed",   final_fare: 97.00 },
  { trip_id: 56, request_id: 56, driver: { driver_id: 32, name: "Heba Sobhy" },       vehicle: { vehicle_id: 2,  model: "Hyundai Elantra",   plate: "DEF-202" }, start_time: new Date("2023-05-28T11:37:00"), end_time: new Date("2023-05-28T12:15:00"), status: "completed",   final_fare: 33.00 },
  { trip_id: 57, request_id: 57, driver: { driver_id: 33, name: "Adel Gaber" },       vehicle: { vehicle_id: 3,  model: "Kia Sportage",      plate: "GHI-303" }, start_time: new Date("2023-05-29T08:08:00"), end_time: new Date("2023-05-29T08:58:00"), status: "completed",   final_fare: 68.00 },
  { trip_id: 58, request_id: 58, driver: { driver_id: 34, name: "Noha Helmy" },       vehicle: { vehicle_id: 4,  model: "Nissan Sunny",      plate: "JKL-404" }, start_time: new Date("2023-05-29T09:09:00"), end_time: new Date("2023-05-29T10:05:00"), status: "completed",   final_fare: 75.00 },
  { trip_id: 59, request_id: 59, driver: { driver_id: 35, name: "Fady Eskander" },    vehicle: { vehicle_id: 5,  model: "Chevrolet Aveo",    plate: "MNO-505" }, start_time: new Date("2023-05-30T10:07:00"), end_time: new Date("2023-05-30T10:52:00"), status: "completed",   final_fare: 48.00 },
  { trip_id: 60, request_id: 60, driver: { driver_id: 36, name: "Ramzy Attia" },      vehicle: { vehicle_id: 6,  model: "Toyota Yaris",      plate: "PQR-606" }, start_time: new Date("2023-05-30T11:06:00"), end_time: new Date("2023-05-30T11:40:00"), status: "completed",   final_fare: 30.00 },
    // ── in progress (60–65) ──
  { trip_id: 61, request_id: 96,  driver: { driver_id: 37, name: "Samir Ghoneim" },   vehicle: { vehicle_id: 7,  model: "Mitsubishi Lancer", plate: "STU-707" }, start_time: new Date("2023-06-18T11:08:00"), end_time: null, status: "in_progress", final_fare: null },
  { trip_id: 62, request_id: 97,  driver: { driver_id: 38, name: "Hossam Fahmy" },    vehicle: { vehicle_id: 8,  model: "Honda Civic",       plate: "VWX-808" }, start_time: new Date("2023-06-19T08:05:00"), end_time: null, status: "in_progress", final_fare: null },
  { trip_id: 63, request_id: 98,  driver: { driver_id: 39, name: "Ashraf Morsy" },    vehicle: { vehicle_id: 9,  model: "Toyota Corolla",    plate: "YZA-909" }, start_time: new Date("2023-06-19T09:07:00"), end_time: null, status: "in_progress", final_fare: null },
  { trip_id: 64, request_id: 99,  driver: { driver_id: 40, name: "Emad Rizk" },       vehicle: { vehicle_id: 10, model: "Hyundai Elantra",   plate: "BCD-110" }, start_time: new Date("2023-06-20T10:06:00"), end_time: null, status: "in_progress", final_fare: null },
  { trip_id: 65, request_id: 100, driver: { driver_id: 41, name: "Walid Aziz" },      vehicle: { vehicle_id: 11, model: "Kia Sportage",      plate: "EFG-211" }, start_time: new Date("2023-06-20T11:05:00"), end_time: null, status: "in_progress", final_fare: null },
];




async function doInsert(trips) {
  const count = await trips.countDocuments();
  if (count > 0) {
    console.log(`\n [Info]: Data already exists (${count} documents).\n`);
    return;
  }
  await trips.insertMany(tripsData);
  console.log(`\n [Success]: Successfully inserted ${tripsData.length} trips.\n`);
}

async function doFind(trips) {
  console.log("\n--- Display & Search Options ---");
  console.log("1 - View ALL trips");
  console.log("2 - Find a SPECIFIC trip by ID");
  const choice = await ask("Choose an option number: ");

  if (choice === "1") {
    
    const allTrips = await trips.find({}).project({ _id: 0 }).toArray();
    
    if (allTrips.length === 0) {
      console.log("\n  No data found in the database.\n");
    } else {
      console.log("\n --- List of All Trips ---");
      console.table(allTrips);
    }

  } else if (choice === "2") {
    
    const idStr = await ask("Enter the Trip ID  to find: ");
    const tripId = parseInt(idStr);

   
    const trip = await trips.findOne({ trip_id: tripId }, { projection: { _id: 0 } });

    if (trip) {
      console.log(`\n  Data found for Trip ID: ${tripId}`);
      console.table([trip]); 
    } else {
      console.log(`\n Error: Trip ID ${tripId} not found.\n`);
    }
  } else {
    console.log("\n  Invalid selection, please choose 1 or 2.\n");
  }
}


async function doUpdate(trips) {
  const idStr = await ask("Enter the Trip ID  to update: ");
  const tripId = parseInt(idStr);

  const trip = await trips.findOne({ trip_id: tripId });
  if (!trip) {
    console.log("\n [Error]: Trip ID not found.\n");
    return;
  }

  console.log("\n What would you like to update?");
  console.log("1 - Status");
  console.log("2 - Final Fare");
  const updateChoice = await ask("Choose an option number: ");

  let updateDoc = {};

  if (updateChoice === "1") {
    const validStatuses = ["completed", "cancelled", "pending"];
    let newStatus = "";
    
    
    while (true) {
      newStatus = (await ask(`Enter new status (${validStatuses.join("/")}): `)).toLowerCase().trim();
      if (validStatuses.includes(newStatus)) {
        break; 
      } else {
        console.log(`\x1b[31m[Error]: Invalid status! Please choose from: ${validStatuses.join(", ")}\x1b[0m`);
      }
    }
    updateDoc = { $set: { status: newStatus } };

  } else if (updateChoice === "2") {
    let newFare = 0;

    
    while (true) {
      const fareInput = await ask("Enter new fare amount (must be positive): ");
      newFare = parseFloat(fareInput);

      if (!isNaN(newFare) && newFare >= 0) {
        break;
      } else {
        console.log("\x1b[31m[Error]: Invalid fare! Please enter a positive number.\x1b[0m");
      }
    }
    updateDoc = { $set: { final_fare: newFare } };

  } else {
    console.log("Invalid choice.");
    return;
  }

  const result = await trips.updateOne({ trip_id: tripId }, updateDoc);
  console.log(`\n [Success]: Updated ${result.modifiedCount} document(s).\n`);
}





function showMenu() {
  console.log("==================================================");
  console.log("         MongoDB - Ride Management System");
  console.log("==================================================");
  console.log("  1 - Insert Data");
  console.log("  2 - Find/View All Trips");
  console.log("  3 - Update a Specific Trip ");
  console.log("  4 - Exit");
  console.log("==================================================");
}

async function main() {
  try {
    await client.connect();
    console.log("\x1b[32m >>> Connected to MongoDB successfully <<<\x1b[0m\n");
    
    const db = client.db("RideSystemDB");
    const trips = db.collection("trips");

    let running = true;
    while (running) {
      showMenu();
      const choice = await ask("Enter your choice: ");

      switch (choice.trim()) {
        case "1": await doInsert(trips); break;
        case "2": await doFind(trips); break;
        case "3": await doUpdate(trips); break;
        case "4": running = false; break;
        default: console.log("\n  Please enter a number between 1 and 5.\n");
      }
    }
  } catch (err) {
    console.error("Critical Error:", err);
  } finally {
    await client.close();
    rl.close();
    console.log("Logged out. Connection closed.");
  }
}

main();