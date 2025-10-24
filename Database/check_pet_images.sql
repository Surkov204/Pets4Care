-- Script kiểm tra ảnh pet trong database
USE [SHOP_PET_Database]
GO

PRINT '=== KIỂM TRA ẢNH PET TRONG DATABASE ==='

-- Kiểm tra dữ liệu pet
SELECT 
    id,
    customer_id,
    pet_name,
    species,
    breed,
    age,
    gender,
    image_path,
    created_at,
    updated_at
FROM Pet
ORDER BY created_at DESC

-- Kiểm tra thống kê
SELECT 
    COUNT(*) as 'Tổng số pet',
    COUNT(image_path) as 'Pet có ảnh',
    COUNT(*) - COUNT(image_path) as 'Pet không có ảnh'
FROM Pet

-- Kiểm tra các đường dẫn ảnh
SELECT DISTINCT image_path 
FROM Pet 
WHERE image_path IS NOT NULL 
ORDER BY image_path

PRINT '=== HOÀN THÀNH KIỂM TRA ==='
