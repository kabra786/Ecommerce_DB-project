-- ============================================================
-- STAGE 1: DATA INSERTION
-- E-Commerce Oracle SQL Project
-- ============================================================

--CREATE TABLE user_temp_map (
    --user_id NUMBER,
    --email VARCHAR2(100)
--);


DECLARE
    v_user_id NUMBER;
    v_name VARCHAR2(50);

    TYPE name_array IS TABLE OF VARCHAR2(50);

    names name_array := name_array(
        'Ahmed Raza', 'Fatima Malik', 'Usman Khan', 'Ayesha Siddiqui',
        'Bilal Ahmed', 'Sana Tariq', 'Zain Abideen', 'Hira Baig',
        'Omar Farooq', 'Nadia Hussain',

        'Ali Hassan', 'Zara Qasim', 'Hamza Iqbal', 'Maira Zafar',
        'Saad Rafiq', 'Aisha Waheed', 'Muneeb Baig', 'Sofia Khan',
        'Waleed Anwar', 'Maryam Shahbaz',

        'Usama Ali', 'Noor Fatima', 'Fahad Sheikh', 'Hania Amir',
        'Taha Javed', 'Rabia Noor', 'Daniyal Ahmed', 'Kiran Aziz',
        'Huzaifa Khan', 'Mehwish Hayat',

        'Talha Asad', 'Iqra Khalid', 'Shayan Ali', 'Sadia Pervez',
        'Farhan Khan', 'Laiba Fatima', 'Imran Ashraf', 'Zunaira Ali',
        'Arslan Malik', 'Mahnoor Khan',

        'Raza Gillani', 'Anaya Shah', 'Hassan Mahmood', 'Sundas Ilyas',
        'Adil Raza', 'Areeba Khan', 'Yasir Niazi', 'Hira Khalid',
        'Kamran Sheikh', 'Saba Ahmed',

        'Noman Ali', 'Aiman Zafar', 'Shahzaib Khan', 'Alina Tariq',
        'Rehan Malik', 'Maham Ali', 'Saifullah Khan', 'Zoya Raza',
        'Ahsan Javed', 'Hina Noor',

        'Faisal Qureshi', 'Aleena Asif', 'Rizwan Haq', 'Eman Fatima',
        'Waqas Ahmed', 'Sana Iqbal', 'Umar Daraz', 'Maryam Ali',
        'Bilal Qadir', 'Ayesha Noor',

        'Shahzad Nawaz', 'Parveen Akhtar', 'Junaid Akram', 'Lubna Shahid',
        'Tayyaba Mir', 'Naveed Hassan', 'Shazia Awan', 'Imran Khan',
        'Nida Ali', 'Zainab Riaz',

        'Owais Malik', 'Hafsa Khan', 'Danish Raza', 'Sumbul Ahmed',
        'Hammad Ali', 'Areej Fatima', 'Asadullah Khan', 'Komal Shah',
        'Usman Ghani', 'Laiba Khan',

        'Arif Mehmood', 'Huma Shafi', 'Shahbaz Ali', 'Aiza Khan',
        'Rameez Raja', 'Nimra Ali', 'Fiza Noor', 'Saima Iqbal',
        'Zubair Ahmed', 'Anum Fatima'
    );

BEGIN
    FOR i IN 1..100 LOOP

        v_name := names(MOD(i-1, names.COUNT) + 1);

        INSERT INTO users (
            user_id,
            name,
            email,
            password,
            phone,
            created_at
        )
        VALUES (
            seq_users.NEXTVAL,
            v_name,
            'user' || i || '@gmail.com',
            'Pass@1234',
            '030000000' || i,
            SYSDATE
        )
        RETURNING user_id INTO v_user_id;

    END LOOP;

    COMMIT;

END;
/

SELECT *
FROM users
ORDER BY user_id;


-- ============================================================
-- ADDRESSES DATA INSERTION (100 ROWS)
-- Compatible with seq_users + existing users table
-- ============================================================

BEGIN

    INSERT INTO addresses VALUES 
    (seq_addresses.NEXTVAL, 1, 'Lahore', 'Punjab', 'Pakistan', '54000', 'Gulberg III, Lahore');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 2, 'Karachi', 'Sindh', 'Pakistan', '75500', 'Clifton Block B, Karachi');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 3, 'Islamabad', 'ICT', 'Pakistan', '44000', 'F-7 Sector, Islamabad');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 4, 'Lahore', 'Punjab', 'Pakistan', '54600', 'DHA Phase 5, Lahore');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 5, 'Peshawar', 'KPK', 'Pakistan', '25000', 'Hayatabad Phase 4');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 6, 'Faisalabad', 'Punjab', 'Pakistan', '38000', 'Peoples Colony');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 7, 'Rawalpindi', 'Punjab', 'Pakistan', '46000', 'Bahria Town Phase 7');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 8, 'Multan', 'Punjab', 'Pakistan', '60000', 'Shah Rukn-e-Alam Colony');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 9, 'Lahore', 'Punjab', 'Pakistan', '54000', 'Model Town');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 10, 'Karachi', 'Sindh', 'Pakistan', '74400', 'North Nazimabad');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 11, 'Quetta', 'Balochistan', 'Pakistan', '87300', 'Jinnah Road');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 12, 'Sialkot', 'Punjab', 'Pakistan', '51310', 'Cantt Area');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 13, 'Hyderabad', 'Sindh', 'Pakistan', '71000', 'Latifabad');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 14, 'Bahawalpur', 'Punjab', 'Pakistan', '63100', 'Satellite Town');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 15, 'Gujranwala', 'Punjab', 'Pakistan', '52250', 'DC Colony');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 16, 'New York', 'NY', 'USA', '10001', '5th Avenue');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 17, 'Los Angeles', 'CA', 'USA', '90001', 'Sunset Boulevard');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 18, 'Chicago', 'IL', 'USA', '60601', 'Michigan Avenue');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 19, 'Houston', 'TX', 'USA', '77001', 'Downtown Street');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 20, 'San Francisco', 'CA', 'USA', '94101', 'Market Street');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 21, 'London', 'England', 'UK', 'SW1A1AA', 'Westminster');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 22, 'Manchester', 'England', 'UK', 'M11AE', 'Oxford Road');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 23, 'Birmingham', 'England', 'UK', 'B11AA', 'City Centre');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 24, 'Liverpool', 'England', 'UK', 'L10AA', 'Albert Dock');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 25, 'Leeds', 'England', 'UK', 'LS11UR', 'Briggate');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 26, 'Mumbai', 'Maharashtra', 'India', '400001', 'Andheri West');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 27, 'Delhi', 'Delhi', 'India', '110001', 'Connaught Place');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 28, 'Bangalore', 'Karnataka', 'India', '560001', 'MG Road');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 29, 'Chennai', 'Tamil Nadu', 'India', '600001', 'T Nagar');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 30, 'Hyderabad', 'Telangana', 'India', '500001', 'Banjara Hills');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 31, 'Dubai', 'Dubai', 'UAE', '00000', 'Downtown Dubai');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 32, 'Abu Dhabi', 'Abu Dhabi', 'UAE', '00000', 'Al Maryah Island');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 33, 'Sharjah', 'Sharjah', 'UAE', '00000', 'Al Nahda');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 34, 'Doha', 'Doha', 'Qatar', '122104', 'West Bay');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 35, 'Muscat', 'Muscat', 'Oman', '112', 'Al Khuwair');
        INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 36, 'Tokyo', 'Tokyo', 'Japan', '1000001', 'Shinjuku');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 37, 'Osaka', 'Osaka', 'Japan', '5300001', 'Umeda');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 38, 'Kyoto', 'Kyoto', 'Japan', '6000001', 'Gion District');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 39, 'Beijing', 'Beijing', 'China', '100000', 'Chaoyang');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 40, 'Shanghai', 'Shanghai', 'China', '200000', 'Pudong');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 41, 'Paris', 'Ile-de-France', 'France', '75000', 'Champs Elysees');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 42, 'Lyon', 'Auvergne', 'France', '69000', 'Bellecour');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 43, 'Berlin', 'Berlin', 'Germany', '10115', 'Alexanderplatz');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 44, 'Munich', 'Bavaria', 'Germany', '80331', 'Marienplatz');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 45, 'Hamburg', 'Hamburg', 'Germany', '20095', 'Altstadt');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 46, 'Rome', 'Lazio', 'Italy', '00100', 'Colosseum Area');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 47, 'Milan', 'Lombardy', 'Italy', '20100', 'Duomo District');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 48, 'Madrid', 'Madrid', 'Spain', '28001', 'Gran Via');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 49, 'Barcelona', 'Catalonia', 'Spain', '08001', 'La Rambla');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 50, 'Valencia', 'Valencia', 'Spain', '46001', 'Old Town');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 51, 'Cairo', 'Cairo', 'Egypt', '11511', 'Tahrir Square');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 52, 'Alexandria', 'Alexandria', 'Egypt', '21500', 'Corniche Road');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 53, 'Riyadh', 'Riyadh', 'Saudi Arabia', '11421', 'King Fahd Road');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 54, 'Jeddah', 'Makkah', 'Saudi Arabia', '21577', 'Corniche');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 55, 'Dammam', 'Eastern Province', 'Saudi Arabia', '31146', 'King Saud Street');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 56, 'Istanbul', 'Istanbul', 'Turkey', '34000', 'Taksim Square');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 57, 'Ankara', 'Ankara', 'Turkey', '06000', 'Kizilay');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 58, 'Izmir', 'Izmir', 'Turkey', '35000', 'Konak');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 59, 'Toronto', 'Ontario', 'Canada', 'M5H2N2', 'Downtown');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 60, 'Vancouver', 'BC', 'Canada', 'V5K0A1', 'Robson Street');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 61, 'Montreal', 'Quebec', 'Canada', 'H1A0A1', 'Old Montreal');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 62, 'Sydney', 'NSW', 'Australia', '2000', 'Opera House Area');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 63, 'Melbourne', 'VIC', 'Australia', '3000', 'CBD');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 64, 'Brisbane', 'QLD', 'Australia', '4000', 'South Bank');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 65, 'Perth', 'WA', 'Australia', '6000', 'Kings Park');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 66, 'Seoul', 'Seoul', 'South Korea', '04524', 'Gangnam');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 67, 'Busan', 'Busan', 'South Korea', '48781', 'Haeundae');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 68, 'Singapore', 'Singapore', 'Singapore', '018956', 'Marina Bay');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 69, 'Kuala Lumpur', 'Selangor', 'Malaysia', '50000', 'Bukit Bintang');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 70, 'Bangkok', 'Bangkok', 'Thailand', '10100', 'Sukhumvit');
        INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 71, 'Jakarta', 'Jakarta', 'Indonesia', '10110', 'Central Jakarta');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 72, 'Manila', 'Metro Manila', 'Philippines', '1000', 'Makati');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 73, 'Hanoi', 'Hanoi', 'Vietnam', '100000', 'Old Quarter');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 74, 'Cape Town', 'Western Cape', 'South Africa', '8001', 'Waterfront');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 75, 'Johannesburg', 'Gauteng', 'South Africa', '2000', 'Sandton');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 76, 'Moscow', 'Moscow', 'Russia', '101000', 'Red Square');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 77, 'Saint Petersburg', 'Leningrad', 'Russia', '190000', 'Nevsky Prospect');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 78, 'Stockholm', 'Stockholm', 'Sweden', '11120', 'Gamla Stan');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 79, 'Oslo', 'Oslo', 'Norway', '0150', 'Karl Johans Gate');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 80, 'Copenhagen', 'Capital Region', 'Denmark', '1050', 'Nyhavn');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 81, 'Zurich', 'Zurich', 'Switzerland', '8001', 'Bahnhofstrasse');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 82, 'Vienna', 'Vienna', 'Austria', '1010', 'Innere Stadt');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 83, 'Brussels', 'Brussels', 'Belgium', '1000', 'Grand Place');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 84, 'Amsterdam', 'North Holland', 'Netherlands', '1012', 'Dam Square');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 85, 'Dublin', 'Leinster', 'Ireland', 'D01', 'Temple Bar');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 86, 'Athens', 'Attica', 'Greece', '10552', 'Syntagma');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 87, 'Lisbon', 'Lisbon', 'Portugal', '1100', 'Alfama');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 88, 'Warsaw', 'Masovian', 'Poland', '00-001', 'Old Town');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 89, 'Prague', 'Prague', 'Czech Republic', '11000', 'Wenceslas Square');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 90, 'Budapest', 'Budapest', 'Hungary', '1011', 'Castle District');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 91, 'Mexico City', 'CDMX', 'Mexico', '01000', 'Reforma Avenue');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 92, 'Sao Paulo', 'Sao Paulo', 'Brazil', '01000', 'Paulista Avenue');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 93, 'Rio de Janeiro', 'Rio', 'Brazil', '22000', 'Copacabana');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 94, 'Buenos Aires', 'Buenos Aires', 'Argentina', '1000', 'Palermo');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 95, 'Santiago', 'Santiago', 'Chile', '8320000', 'Providencia');

    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 96, 'Auckland', 'Auckland', 'New Zealand', '1010', 'Queen Street');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 97, 'Wellington', 'Wellington', 'New Zealand', '6011', 'Lambton Quay');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 98, 'Kathmandu', 'Bagmati', 'Nepal', '44600', 'Thamel');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 99, 'Colombo', 'Western', 'Sri Lanka', '00100', 'Galle Road');
    INSERT INTO addresses VALUES (seq_addresses.NEXTVAL, 100, 'Dhaka', 'Dhaka', 'Bangladesh', '1205', 'Banani');

    COMMIT;

END;
/

SELECT *
FROM addresses
ORDER BY address_id;


-- ------------------------------------------------------------
-- CATEGORIES (10)
-- ------------------------------------------------------------

INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Electronics', 'Gadgets, devices, computers, phones and accessories');
INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Fashion', 'Clothing, shoes, accessories and apparel for all ages');
INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Home', 'Furniture, decor, kitchen and household items');
INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Books', 'Fiction, non-fiction, academic and educational books');
INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Beauty', 'Skincare, makeup, haircare and personal care products');
INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Sports', 'Equipment, activewear and outdoor sports gear');
INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Toys', 'Toys and games for children of all ages');
INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Grocery', 'Food, beverages, snacks and pantry essentials');
INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Automotive', 'Car accessories, tools and auto parts');
INSERT INTO categories VALUES (seq_categories.NEXTVAL, 'Health', 'Vitamins, supplements, medical devices and wellness products');

COMMIT;

SELECT *
FROM categories;


-- ------------------------------------------------------------
-- PRODUCTS (~100 total, 10 per category)
-- category_id 1=Electronics 2=Fashion 3=Home 4=Books 5=Beauty
--             6=Sports 7=Toys 8=Grocery 9=Automotive 10=Health
-- ------------------------------------------------------------

-- Electronics (cat 1)
SET DEFINE OFF;

INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Samsung Galaxy S24 Ultra', '6.8-inch Dynamic AMOLED, 200MP camera, 5000mAh battery', 1299.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Apple iPhone 15 Pro', 'A17 Pro chip, titanium design, 48MP main camera', 1199.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Sony WH-1000XM5 Headphones', 'Industry-leading noise cancellation, 30-hour battery', 349.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Dell XPS 15 Laptop', '15.6-inch OLED, Intel Core i9, 32GB RAM, 1TB SSD', 1899.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Apple MacBook Air M2', '13.6-inch Liquid Retina, M2 chip, 8GB RAM, 256GB SSD', 1099.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Amazon Echo Dot 5th Gen', 'Smart speaker with Alexa, improved bass and sound', 49.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Samsung 55-inch 4K QLED TV', 'Quantum HDR, Smart TV, 120Hz refresh rate', 799.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Canon EOS R50 Camera', 'Mirrorless, 24.2MP APS-C sensor, 4K video', 679.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Apple Watch Series 9', 'Always-on Retina display, health monitoring, GPS', 399.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 1, 'Logitech MX Master 3S Mouse', 'Ergonomic wireless mouse, 8000 DPI, silent clicks', 99.99, SYSDATE);

-- Fashion (cat 2)
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'Levi''s 501 Original Fit Jeans', 'Classic straight leg, 100% cotton denim, multiple colors', 59.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'Nike Air Max 270 Sneakers', 'Lightweight, breathable, Max Air cushioning', 149.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'Adidas Ultraboost 22 Running Shoes', 'Responsive Boost midsole, Primeknit upper', 179.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'Ralph Lauren Polo Shirt', 'Classic fit, 100% cotton pique, iconic polo design', 89.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'Zara Floral Midi Dress', 'V-neck floral print, flowy fabric, summer collection', 49.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'North Face Thermoball Jacket', 'Lightweight puffer, water-repellent, packable design', 199.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'Ray-Ban Aviator Sunglasses', 'Classic metal frame, UV400 protection, polarized lens', 154.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'Calvin Klein Slim Fit Chinos', 'Stretch fabric, tapered leg, modern cut', 69.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'Gucci GG Canvas Belt', 'Signature GG buckle, genuine leather strap', 299.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 2, 'H&M Basic Cotton T-Shirt Pack', 'Pack of 3, round neck, 100% organic cotton', 29.99, SYSDATE);

-- Home (cat 3)
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'Instant Pot Duo 7-in-1', 'Electric pressure cooker, 6 quart, 14 smart programs', 99.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'Dyson V15 Detect Vacuum', 'Laser dust detection, HEPA filtration, 60-min runtime', 649.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'KitchenAid Stand Mixer', '5-quart, 10-speed, tilt-head design, includes 3 attachments', 449.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'Philips Hue Smart Bulb Starter Kit', '4 bulbs, hub included, 16 million colors, voice control', 199.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'IKEA MALM Bed Frame Queen', 'Clean design, solid wood, with slatted base included', 299.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'Ninja Foodi Air Fryer', '6-quart, 8-in-1 cooking system, ceramic coated basket', 149.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'Calphalon Nonstick Cookware Set', '10-piece set, hard-anodized aluminum, oven safe', 249.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'Tempur-Pedic Memory Foam Pillow', 'Original Tempur material, cool-to-touch cover, queen size', 79.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'Nespresso Vertuo Coffee Machine', 'Single serve, 5 cup sizes, fast heat-up, chrome design', 189.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 3, 'LEVOIT Air Purifier H13 HEPA', 'Covers 1095 sq ft, removes 99.97% allergens, quiet mode', 129.99, SYSDATE);

-- Books (cat 4)
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, 'Atomic Habits by James Clear', 'Proven framework for building good habits, bestseller', 16.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, 'The Great Gatsby by F. Scott Fitzgerald', 'Classic American novel, Jazz Age masterpiece', 12.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, 'Sapiens by Yuval Noah Harari', 'Brief history of humankind, global bestseller', 18.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, 'Harry Potter Complete Box Set', 'All 7 books in hardcover, illustrated collector edition', 89.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, 'Clean Code by Robert C. Martin', 'Handbook of agile software craftsmanship for developers', 39.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, 'The Alchemist by Paulo Coelho', 'Philosophical novel about following your dreams', 14.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, 'Thinking Fast and Slow by Daniel Kahneman', 'Nobel Prize winner explores dual systems of thinking', 17.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, '1984 by George Orwell', 'Dystopian social science fiction classic novel', 13.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, 'Introduction to Algorithms (CLRS)', 'Comprehensive textbook on computer algorithms, 4th edition', 89.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 4, 'Rich Dad Poor Dad by Robert Kiyosaki', 'Personal finance and investing advice for beginners', 15.99, SYSDATE);

-- Beauty (cat 5)
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'CeraVe Moisturizing Cream 19oz', 'Fragrance-free, develops ceramides, dermatologist recommended', 18.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'Neutrogena Hydro Boost Water Gel', 'Hyaluronic acid, lightweight, non-comedogenic moisturizer', 22.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'Maybelline Fit Me Foundation', '40 shades, natural coverage, shine-free finish', 9.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'L Oreal Paris Elvive Shampoo', 'Extraordinary oil, sulfate-free, for dry damaged hair', 11.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'The Ordinary Niacinamide 10% Serum', 'Reduces blemishes, balances sebum, brightens skin tone', 7.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'Dove Deep Moisture Body Wash', '22oz, NutriumMoisture technology, gentle cleansing', 8.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'MAC Ruby Woo Lipstick', 'Iconic matte red, long-wearing, intensely pigmented', 21.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'Olay Regenerist Micro-Sculpting Cream', 'Advanced anti-aging moisturizer with hyaluronic acid', 28.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'Pantene Pro-V Conditioner', 'Smooth and sleek, anti-frizz, 12oz bottle', 10.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 5, 'Gillette Fusion5 ProGlide Razor', '5-blade razors, flexball handle, 4-blade pack', 24.99, SYSDATE);

SELECT * FROM products;

-- Sports (cat 6)
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'Wilson Evolution Basketball', 'Official size 7, composite leather, indoor use', 69.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'Spalding NFL Football', 'Official size, leather cover, American football', 49.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'Bowflex SelectTech 552 Dumbbells', 'Adjustable 5-52.5 lbs each, replaces 15 sets of weights', 429.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'Peloton Yoga Mat', 'Non-slip, 68-inch, 6mm thick, moisture-wicking', 44.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'Garmin Forerunner 255 GPS Watch', 'Running dynamics, heart rate, multi-sport tracking', 349.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'Callaway Strata Golf Club Set', '12-piece complete set, men''s right hand, bag included', 249.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'Coleman 6-Person Tent', 'WeatherTec system, 10-minute setup, carry bag', 149.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'Schwinn IC4 Indoor Cycling Bike', 'Bluetooth connectivity, 100 resistance levels, LCD display', 799.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'Head Ti.S6 Tennis Racket', 'Titanium alloy, oversize head, pre-strung', 34.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 6, 'TRX All-in-One Suspension Trainer', 'Pro-grade straps, door anchor, travel-ready workout system', 179.99, SYSDATE);

-- Toys (cat 7)
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'LEGO Technic Bugatti Chiron Set', '3599 pieces, 1:8 scale, detailed engine and gearbox', 349.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'Barbie Dreamhouse Playset', '3-story, 8 rooms, 70+ accessories, slide and elevator', 199.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'Nerf Elite 2.0 Commander Blaster', '6-dart rotating drum, slam-fire, for ages 8+', 14.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'Fisher-Price Laugh and Learn', 'Smart stages learning toy, music and lights, ages 6-36 mo', 29.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'Hot Wheels Ultimate Garage Playset', '4-feet tall, 140+ car capacity, includes 2 cars', 89.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'Monopoly Classic Board Game', 'Classic property trading game, 2-8 players, ages 8+', 24.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'Play-Doh Mega Fun Factory Set', '14 tools, 15 colors, non-toxic, ages 3+', 34.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'Melissa and Doug Wooden Puzzles', 'Set of 4, chunky knob puzzles, ages 2-4', 19.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'Remote Control Monster Truck', '1:10 scale, 4WD, all-terrain, 40 mph top speed', 79.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 7, 'UNO Card Game Classic', 'Standard deck, 112 cards, 2-10 players, ages 7+', 9.99, SYSDATE);

--GROCERY (CAT 8)
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Quaker Old Fashioned Oats 18oz', 'Whole grain oats, non-GMO, heart-healthy breakfast', 5.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Nestle Coffee-Mate Creamer 35.3oz', 'Original flavor, powder, lactose-free coffee creamer', 12.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Heinz Tomato Ketchup 64oz', 'No artificial preservatives, classic taste, large bottle', 8.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Basmati Rice Premium 10lb Bag', 'Long grain, aged, aromatic and fluffy', 24.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Tropicana Orange Juice 52oz', 'No pulp, vitamin C rich, fresh taste', 6.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Oreo Family Pack Cookies', 'Classic chocolate sandwich cookies', 5.49, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Extra Virgin Olive Oil 1L', 'Cold pressed, premium quality', 19.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Lipton Yellow Label Tea 100 Bags', 'Strong black tea blend', 7.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Kellogg’s Corn Flakes 18oz', 'Crispy breakfast cereal', 4.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 8, 'Skippy Peanut Butter 40oz', 'Smooth creamy peanut butter', 9.99, SYSDATE);

--AUTOMOTIVE (CAT 9)
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'Bosch Tire Pressure Gauge', 'Digital accurate PSI reading tool', 24.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'Armor All Car Care Kit', 'Interior and exterior cleaning kit', 34.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'BlackVue 4K Dash Cam', 'Front and rear recording, cloud support', 399.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'Michelin Jumper Cables Heavy Duty', '25ft durable emergency cables', 59.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'Anker Car USB Charger', 'Fast dual-port charging', 15.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'WeatherTech Floor Mats Custom Fit', 'Laser measured car mats', 149.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'Chemical Guys Car Wash Kit', 'Complete detailing kit', 79.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'DEWALT Jump Starter 20V', 'Portable high power starter', 129.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'Garmin GPS Navigator 6.95"', 'Real-time traffic navigation', 179.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 9, 'Thule Bike Rack Pro XT', 'Premium 2-bike rack system', 599.99, SYSDATE);

--HEALTH (CAT 10)
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Optimum Nutrition Whey Protein 5lb', 'High protein muscle recovery supplement', 59.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Vitamin D3 2000 IU Nature Made', 'Bone and immune support supplement', 19.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Omron Blood Pressure Monitor', 'Bluetooth medical grade BP monitor', 79.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Garden of Life Multivitamin Men', 'Whole food vitamin formula', 34.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Fitbit Charge 6 Tracker', 'Fitness and heart rate monitoring', 159.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Centrum Silver 50+ Multivitamin', 'Daily senior health support', 22.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Vicks VapoRub 6oz', 'Cold and cough relief ointment', 10.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Omega-3 Fish Oil Nordic Naturals', 'Heart health supplement', 29.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Infrared Forehead Thermometer', 'Non-contact fast reading', 34.99, SYSDATE);
INSERT INTO products VALUES (seq_products.NEXTVAL, 10, 'Protein Bar MusclePharm 12 Pack', 'High protein snack bars', 26.99, SYSDATE);

SELECT * FROM products;

--===========================================================
-- SELECT * FROM products;

-- INSERT INTO product_images VALUES (seq_images.NEXTVAL, 1, 'https://images.pexels.com/photos/404280/pexels-photo-404280.jpeg');
--===========================================================


INSERT INTO product_images VALUES (seq_images.NEXTVAL, 2, 'https://images.pexels.com/photos/699122/pexels-photo-699122.jpeg');

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 3, 'https://images.pexels.com/photos/3394650/pexels-photo-3394650.jpeg');

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 4, 'https://images.pexels.com/photos/18105/pexels-photo.jpg');

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 5, 'https://images.pexels.com/photos/205421/pexels-photo-205421.jpeg');

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 6, 'https://images.pexels.com/photos/4790268/pexels-photo-4790268.jpeg');

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 7, 'https://images.pexels.com/photos/1201996/pexels-photo-1201996.jpeg');

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 8, 'https://images.pexels.com/photos/51383/photo-camera-subject-photographer-51383.jpeg');

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 9, 'https://images.pexels.com/photos/437037/pexels-photo-437037.jpeg');

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 10, 'https://images.pexels.com/photos/2115256/pexels-photo-2115256.jpeg');

COMMIT;

-- Fashion images (products 11-20)

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 11, 'https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 12, 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 13, 'https://images.pexels.com/photos/19090/pexels-photo.jpg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 14, 'https://images.pexels.com/photos/428340/pexels-photo-428340.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 15, 'https://images.pexels.com/photos/1462637/pexels-photo-1462637.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 16, 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 17, 'https://images.pexels.com/photos/46710/pexels-photo-46710.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 18, 'https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 19, 'https://images.pexels.com/photos/45055/pexels-photo-45055.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 20, 'https://images.pexels.com/photos/996329/pexels-photo-996329.jpeg');

-- ------------------------------------------------------------
-- Home images (products 21-30)
-- 1 image per product
-- ------------------------------------------------------------

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 21, 'https://images.pexels.com/photos/699608/pexels-photo-699608.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 22, 'https://images.pexels.com/photos/410871/pexels-photo-410871.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 23, 'https://images.pexels.com/photos/2762247/pexels-photo-2762247.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 24, 'https://images.pexels.com/photos/577514/pexels-photo-577514.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 25, 'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 26, 'https://images.pexels.com/photos/699614/pexels-photo-699614.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 27, 'https://images.pexels.com/photos/582490/pexels-photo-582490.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 28, 'https://images.pexels.com/photos/3756523/pexels-photo-3756523.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 29, 'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 30, 'https://images.pexels.com/photos/3689532/pexels-photo-3689532.jpeg');

-- ------------------------------------------------------------
-- Books images (products 31-40)
-- ------------------------------------------------------------

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 31, 'https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 32, 'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 33, 'https://images.pexels.com/photos/1370295/pexels-photo-1370295.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 34, 'https://images.pexels.com/photos/46274/pexels-photo-46274.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 35, 'https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 36, 'https://images.pexels.com/photos/904616/pexels-photo-904616.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 37, 'https://images.pexels.com/photos/159866/books-book-pages-read-literature-159866.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 38, 'https://images.pexels.com/photos/590493/pexels-photo-590493.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 39, 'https://images.pexels.com/photos/4145190/pexels-photo-4145190.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 40, 'https://images.pexels.com/photos/3747468/pexels-photo-3747468.jpeg');

-- Beauty images (products 41-50)

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 41, 'https://images.pexels.com/photos/6621330/pexels-photo-6621330.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 42, 'https://images.pexels.com/photos/4465124/pexels-photo-4465124.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 43, 'https://images.pexels.com/photos/2533266/pexels-photo-2533266.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 44, 'https://images.pexels.com/photos/3738348/pexels-photo-3738348.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 45, 'https://images.pexels.com/photos/3373746/pexels-photo-3373746.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 46, 'https://images.pexels.com/photos/3735657/pexels-photo-3735657.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 47, 'https://images.pexels.com/photos/2113855/pexels-photo-2113855.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 48, 'https://images.pexels.com/photos/3762879/pexels-photo-3762879.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 49, 'https://images.pexels.com/photos/7755655/pexels-photo-7755655.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 50, 'https://images.pexels.com/photos/6621143/pexels-photo-6621143.jpeg');

-- Sports images (products 51-60)

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 51, 'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 52, 'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 53, 'https://images.pexels.com/photos/416717/pexels-photo-416717.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 54, 'https://images.pexels.com/photos/2294361/pexels-photo-2294361.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 55, 'https://images.pexels.com/photos/3757952/pexels-photo-3757952.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 56, 'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 57, 'https://images.pexels.com/photos/863988/pexels-photo-863988.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 58, 'https://images.pexels.com/photos/2261485/pexels-photo-2261485.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 59, 'https://images.pexels.com/photos/163444/sport-treadmill-tor-route-163444.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 60, 'https://images.pexels.com/photos/28080/pexels-photo.jpg');

-- Toys images (products 61-70)

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 61, 'https://images.pexels.com/photos/3661197/pexels-photo-3661197.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 62, 'https://images.pexels.com/photos/3756766/pexels-photo-3756766.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 63, 'https://images.pexels.com/photos/163036/mario-luigi-toys-figures-163036.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 64, 'https://images.pexels.com/photos/47730/the-ball-stadion-football-the-pitch-47730.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 65, 'https://images.pexels.com/photos/163036/lego-toys-blocks-colorful-163036.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 66, 'https://images.pexels.com/photos/3932965/pexels-photo-3932965.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 67, 'https://images.pexels.com/photos/325075/pexels-photo-325075.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 68, 'https://images.pexels.com/photos/1337380/pexels-photo-1337380.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 69, 'https://images.pexels.com/photos/159211/toy-car-model-vintage-159211.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 70, 'https://images.pexels.com/photos/1148998/pexels-photo-1148998.jpeg');

-- Grocery images (products 71-80)

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 71, 'https://images.pexels.com/photos/1660030/pexels-photo-1660030.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 72, 'https://images.pexels.com/photos/1435735/pexels-photo-1435735.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 73, 'https://images.pexels.com/photos/3026808/pexels-photo-3026808.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 74, 'https://images.pexels.com/photos/5945900/pexels-photo-5945900.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 75, 'https://images.pexels.com/photos/128402/pexels-photo-128402.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 76, 'https://images.pexels.com/photos/129350/pexels-photo-129350.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 77, 'https://images.pexels.com/photos/162583/coffee-beans-cup-coffee-espresso-162583.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 78, 'https://images.pexels.com/photos/1638280/pexels-photo-1638280.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 79, 'https://images.pexels.com/photos/1132047/pexels-photo-1132047.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 80, 'https://images.pexels.com/photos/1407395/pexels-photo-1407395.jpeg');

-- Automotive images (products 81-90)

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 81, 'https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 82, 'https://images.pexels.com/photos/210019/pexels-photo-210019.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 83, 'https://images.pexels.com/photos/1007410/pexels-photo-1007410.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 84, 'https://images.pexels.com/photos/3729464/pexels-photo-3729464.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 85, 'https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 86, 'https://images.pexels.com/photos/248747/pexels-photo-248747.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 87, 'https://images.pexels.com/photos/1231643/pexels-photo-1231643.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 88, 'https://images.pexels.com/photos/164634/pexels-photo-164634.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 89, 'https://images.pexels.com/photos/97075/pexels-photo-97075.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 90, 'https://images.pexels.com/photos/210019/pexels-photo-210019.jpeg');

-- Health images (products 91-100)

INSERT INTO product_images VALUES (seq_images.NEXTVAL, 91, 'https://images.pexels.com/photos/3683074/pexels-photo-3683074.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 92, 'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 93, 'https://images.pexels.com/photos/4021775/pexels-photo-4021775.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 94, 'https://images.pexels.com/photos/3683073/pexels-photo-3683073.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 95, 'https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 96, 'https://images.pexels.com/photos/3873179/pexels-photo-3873179.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 97, 'https://images.pexels.com/photos/3683072/pexels-photo-3683072.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 98, 'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 99, 'https://images.pexels.com/photos/3985161/pexels-photo-3985161.jpeg');
INSERT INTO product_images VALUES (seq_images.NEXTVAL, 100, 'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg');

SELECT * FROM product_images;

-- ------------------------------------------------------------
-- INVENTORY (1 per product, stock 0-500)
-- ------------------------------------------------------------

INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 1, 245, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 2, 132, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 3, 310, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 4, 89, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 5, 175, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 6, 420, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 7, 63, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 8, 198, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 9, 147, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 10, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 11, 380, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 12, 210, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 13, 295, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 14, 150, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 15, 430, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 16, 75, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 17, 320, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 18, 260, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 19, 40, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 20, 490, SYSDATE);

INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 21, 185, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 22, 55, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 23, 120, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 24, 350, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 25, 95, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 26, 410, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 27, 230, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 28, 470, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 29, 160, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 30, 285, SYSDATE);

INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 31, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 32, 450, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 33, 380, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 34, 120, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 35, 200, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 36, 490, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 37, 310, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 38, 420, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 39, 85, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 40, 340, SYSDATE);

INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 41, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 42, 430, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 43, 390, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 44, 275, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 45, 460, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 46, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 47, 180, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 48, 320, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 49, 410, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 50, 240, SYSDATE);

INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 51, 155, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 52, 200, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 53, 45, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 54, 370, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 55, 130, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 56, 90, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 57, 215, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 58, 30, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 59, 480, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 60, 165, SYSDATE);

INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 61, 70, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 62, 140, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 63, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 64, 395, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 65, 110, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 66, 450, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 67, 275, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 68, 360, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 69, 195, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 70, 480, SYSDATE);

INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 71, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 72, 470, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 73, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 74, 490, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 75, 460, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 76, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 77, 480, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 78, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 79, 490, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 80, 470, SYSDATE);

INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 81, 300, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 82, 250, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 83, 80, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 84, 175, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 85, 420, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 86, 95, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 87, 145, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 88, 60, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 89, 115, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 90, 35, SYSDATE);

INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 91, 330, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 92, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 93, 140, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 94, 400, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 95, 210, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 96, 490, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 97, 500, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 98, 280, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 99, 175, SYSDATE);
INSERT INTO inventory VALUES (seq_inventory.NEXTVAL, 100, 350, SYSDATE);

COMMIT;

SELECT * FROM inventory;


-- ------------------------------------------------------------
-- CART_ITEMS
-- ------------------------------------------------------------

INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 1,  3,  1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 1,  12, 2, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 2,  5,  1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 2,  21, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 3,  7,  1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 3,  31, 3, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 4,  42, 2, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 4,  55, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 5,  63, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 5,  74, 2, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 6,  80, 4, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 6,  91, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 7,  2,  1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 7,  14, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 8,  23, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 8,  36, 2, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 9,  47, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 9,  58, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 10, 67, 2, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 10, 78, 3, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 11, 1,  1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 12, 9,  1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 13, 19, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 14, 29, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 15, 39, 2, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 16, 49, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 17, 59, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 18, 69, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 19, 79, 5, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 20, 89, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 21, 99, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 22, 11, 2, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 23, 22, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 24, 33, 1, SYSDATE);
INSERT INTO cart_items VALUES (seq_cart_items.NEXTVAL, 25, 44, 1, SYSDATE);

SELECT * FROM cart_items;

-- ------------------------------------------------------------
-- WISHLISTS
-- ------------------------------------------------------------

INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 1,  1,  SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 1,  7,  SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 2,  2,  SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 2,  22, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 3,  5,  SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 3,  53, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 4,  9,  SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 4,  41, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 5,  16, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 5,  61, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 6,  4,  SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 6,  32, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 7,  13, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 7,  73, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 8,  24, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 8,  84, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 9,  35, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 9,  95, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 10, 46, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 10, 56, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 11, 8,  SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 12, 18, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 13, 28, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 14, 38, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 15, 48, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 16, 58, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 17, 68, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 18, 78, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 19, 88, SYSDATE);
INSERT INTO wishlists VALUES (seq_wishlists.NEXTVAL, 20, 98, SYSDATE);

SELECT * FROM wishlists;

-- ------------------------------------------------------------
-- ORDERS (100 orders)
-- ------------------------------------------------------------

INSERT INTO orders VALUES (seq_orders.NEXTVAL, 1,  SYSDATE - 90, 1649.98, 'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 2,  SYSDATE - 88, 349.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 3,  SYSDATE - 85, 99.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 4,  SYSDATE - 83, 1899.99, 'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 5,  SYSDATE - 80, 209.98,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 6,  SYSDATE - 78, 449.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 7,  SYSDATE - 75, 799.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 8,  SYSDATE - 73, 679.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 9,  SYSDATE - 70, 399.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 10, SYSDATE - 68, 99.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 11, SYSDATE - 65, 59.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 12, SYSDATE - 63, 149.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 13, SYSDATE - 60, 179.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 14, SYSDATE - 58, 199.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 15, SYSDATE - 55, 49.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 16, SYSDATE - 53, 154.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 17, SYSDATE - 50, 69.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 18, SYSDATE - 48, 29.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 19, SYSDATE - 45, 99.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 20, SYSDATE - 43, 649.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 21, SYSDATE - 40, 449.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 22, SYSDATE - 38, 199.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 23, SYSDATE - 35, 149.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 24, SYSDATE - 33, 249.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 25, SYSDATE - 30, 79.99,   'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 26, SYSDATE - 28, 129.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 27, SYSDATE - 25, 189.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 28, SYSDATE - 23, 16.99,   'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 29, SYSDATE - 20, 18.99,   'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 30, SYSDATE - 18, 89.99,   'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 31, SYSDATE - 15, 39.99,   'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 32, SYSDATE - 14, 14.99,   'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 33, SYSDATE - 13, 17.99,   'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 34, SYSDATE - 12, 13.99,   'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 35, SYSDATE - 11, 89.99,   'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 36, SYSDATE - 10, 15.99,   'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 37, SYSDATE - 9,  18.99,   'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 38, SYSDATE - 9,  22.99,   'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 39, SYSDATE - 8,  9.99,    'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 40, SYSDATE - 8,  11.99,   'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 41, SYSDATE - 7,  7.99,    'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 42, SYSDATE - 7,  8.99,    'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 43, SYSDATE - 6,  21.99,   'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 44, SYSDATE - 6,  28.99,   'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 45, SYSDATE - 5,  10.99,   'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 46, SYSDATE - 5,  24.99,   'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 47, SYSDATE - 4,  69.99,   'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 48, SYSDATE - 4,  49.99,   'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 49, SYSDATE - 3,  429.99,  'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 50, SYSDATE - 3,  44.99,   'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 1,  SYSDATE - 75, 349.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 3,  SYSDATE - 60, 1099.99, 'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 5,  SYSDATE - 50, 49.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 7,  SYSDATE - 42, 34.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 9,  SYSDATE - 35, 249.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 11, SYSDATE - 28, 149.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 13, SYSDATE - 22, 349.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 15, SYSDATE - 16, 199.99,  'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 17, SYSDATE - 10, 89.99,   'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 19, SYSDATE - 5,  34.99,   'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 2,  SYSDATE - 70, 799.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 4,  SYSDATE - 55, 679.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 6,  SYSDATE - 44, 399.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 8,  SYSDATE - 33, 99.99,   'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 10, SYSDATE - 21, 59.99,   'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 12, SYSDATE - 12, 149.99,  'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 14, SYSDATE - 6,  179.99,  'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 31, SYSDATE - 80, 1299.99, 'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 32, SYSDATE - 65, 1199.99, 'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 33, SYSDATE - 50, 49.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 34, SYSDATE - 40, 59.99,   'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 35, SYSDATE - 30, 29.99,   'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 36, SYSDATE - 20, 79.99,   'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 37, SYSDATE - 10, 9.99,    'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 38, SYSDATE - 5,  24.99,   'PENDING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 71, SYSDATE - 75, 649.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 72, SYSDATE - 60, 449.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 73, SYSDATE - 45, 199.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 74, SYSDATE - 30, 149.99,  'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 77, SYSDATE - 70, 429.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 78, SYSDATE - 55, 349.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 79, SYSDATE - 40, 179.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 80, SYSDATE - 20, 99.99,   'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 83, SYSDATE - 60, 399.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 84, SYSDATE - 45, 599.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 85, SYSDATE - 30, 249.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 86, SYSDATE - 15, 159.99,  'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 87, SYSDATE - 85, 1099.99, 'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 88, SYSDATE - 70, 799.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 89, SYSDATE - 55, 349.99,  'DELIVERED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 90, SYSDATE - 40, 199.99,  'SHIPPED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 91, SYSDATE - 25, 149.99,  'PROCESSING');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 92, SYSDATE - 10, 79.99,   'CONFIRMED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 93, SYSDATE - 5,  44.99,   'CANCELLED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 94, SYSDATE - 3,  299.99,  'CANCELLED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 95, SYSDATE - 60, 59.99,   'RETURNED');
INSERT INTO orders VALUES (seq_orders.NEXTVAL, 96, SYSDATE - 45, 129.99,  'REFUNDED');

SELECT * FROM orders;

-- ------------------------------------------------------------
-- ORDER_ITEMS
-- ------------------------------------------------------------

INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 1,  3,  1, 349.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 1,  12, 2, 149.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 2,  3,  1, 349.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 3,  21, 1, 99.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 4,  4,  1, 1899.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 5,  15, 1, 49.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 5,  20, 2, 29.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 6,  23, 1, 449.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 7,  7,  1, 799.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 8,  8,  1, 679.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 9,  9,  1, 399.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 10, 10, 1, 99.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 11, 11, 1, 59.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 12, 12, 1, 149.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 13, 13, 1, 179.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 14, 16, 1, 199.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 15, 15, 1, 49.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 16, 17, 1, 154.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 17, 18, 1, 69.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 18, 20, 1, 29.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 19, 21, 1, 99.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 20, 22, 1, 649.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 21, 23, 1, 449.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 22, 24, 1, 199.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 23, 26, 1, 149.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 24, 27, 1, 249.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 25, 28, 1, 79.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 26, 30, 1, 129.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 27, 29, 1, 189.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 28, 31, 1, 16.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 29, 33, 1, 18.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 30, 34, 1, 89.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 31, 35, 1, 39.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 32, 36, 1, 14.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 33, 37, 1, 17.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 34, 38, 1, 13.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 35, 39, 1, 89.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 36, 40, 1, 15.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 37, 41, 1, 18.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 38, 42, 1, 22.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 39, 43, 1, 9.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 40, 44, 1, 11.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 41, 45, 1, 7.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 42, 46, 1, 8.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 43, 47, 1, 21.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 44, 48, 1, 28.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 45, 49, 1, 10.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 46, 50, 1, 24.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 47, 51, 1, 69.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 48, 52, 1, 49.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 49, 53, 1, 429.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 50, 54, 1, 44.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 51, 3,  1, 349.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 52, 5,  1, 1099.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 53, 15, 1, 49.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 54, 63, 1, 34.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 55, 56, 1, 249.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 56, 26, 1, 149.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 57, 61, 1, 349.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 58, 24, 1, 199.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 59, 89, 1, 34.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 60, 7,  1, 799.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 61, 8,  1, 679.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 62, 6,  1, 399.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 63, 64, 1, 99.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 64, 10, 1, 59.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 65, 12, 1, 149.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 66, 13, 1, 179.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 67, 1,  1, 1299.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 68, 2,  1, 1199.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 69, 15, 1, 49.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 70, 91, 1, 59.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 71, 20, 1, 29.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 72, 82, 1, 79.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 73, 70, 1, 9.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 74, 84, 1, 24.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 75, 22, 1, 649.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 76, 23, 1, 449.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 77, 24, 1, 199.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 78, 30, 1, 99.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 79, 83, 1, 399.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 80, 90, 1, 599.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 81, 56, 1, 249.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 82, 95, 1, 159.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 83, 5,  1, 1099.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 84, 7,  1, 799.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 85, 61, 1, 349.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 86, 62, 1, 199.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 87, 26, 1, 149.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 88, 93, 1, 79.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 89, 54, 1, 44.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 90, 16, 1, 299.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 91, 91, 1, 59.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 92, 91, 2, 129.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 93, 91, 1, 44.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 94, 16, 1, 299.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 95, 91, 1, 59.99);
INSERT INTO order_items VALUES (seq_order_items.NEXTVAL, 96, 30, 1, 129.99);

SELECT * FROM order_items;

-- ------------------------------------------------------------
-- PAYMENTS
-- ------------------------------------------------------------

INSERT INTO payments VALUES (seq_payments.NEXTVAL, 1,  'CREDIT_CARD',      'COMPLETED', SYSDATE - 90, 1649.98);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 2,  'PAYPAL',           'COMPLETED', SYSDATE - 88, 349.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 3,  'DEBIT_CARD',       'COMPLETED', SYSDATE - 85, 99.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 4,  'CREDIT_CARD',      'COMPLETED', SYSDATE - 83, 1899.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 5,  'CASH_ON_DELIVERY', 'COMPLETED', SYSDATE - 80, 209.98);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 6,  'CREDIT_CARD',      'COMPLETED', SYSDATE - 78, 449.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 7,  'BANK_TRANSFER',    'COMPLETED', SYSDATE - 75, 799.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 8,  'CREDIT_CARD',      'COMPLETED', SYSDATE - 73, 679.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 9,  'WALLET',           'COMPLETED', SYSDATE - 70, 399.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 10, 'PAYPAL',           'COMPLETED', SYSDATE - 68, 99.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 11, 'DEBIT_CARD',       'COMPLETED', SYSDATE - 65, 59.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 12, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 63, 149.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 13, 'CASH_ON_DELIVERY', 'COMPLETED', SYSDATE - 60, 179.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 14, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 58, 199.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 15, 'WALLET',           'COMPLETED', SYSDATE - 55, 49.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 16, 'PAYPAL',           'COMPLETED', SYSDATE - 53, 154.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 17, 'DEBIT_CARD',       'COMPLETED', SYSDATE - 50, 69.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 18, 'CASH_ON_DELIVERY', 'COMPLETED', SYSDATE - 48, 29.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 19, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 45, 99.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 20, 'BANK_TRANSFER',    'COMPLETED', SYSDATE - 43, 649.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 21, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 40, 449.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 22, 'PAYPAL',           'COMPLETED', SYSDATE - 38, 199.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 23, 'DEBIT_CARD',       'COMPLETED', SYSDATE - 35, 149.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 24, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 33, 249.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 25, 'WALLET',           'COMPLETED', SYSDATE - 30, 79.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 26, 'CASH_ON_DELIVERY', 'COMPLETED', SYSDATE - 28, 129.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 27, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 25, 189.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 28, 'PAYPAL',           'COMPLETED', SYSDATE - 23, 16.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 29, 'DEBIT_CARD',       'COMPLETED', SYSDATE - 20, 18.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 30, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 18, 89.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 31, 'WALLET',           'PENDING',   SYSDATE - 15, 39.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 32, 'CREDIT_CARD',      'PENDING',   SYSDATE - 14, 14.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 33, 'CASH_ON_DELIVERY', 'PENDING',   SYSDATE - 13, 17.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 34, 'PAYPAL',           'PENDING',   SYSDATE - 12, 13.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 35, 'DEBIT_CARD',       'PENDING',   SYSDATE - 11, 89.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 36, 'CREDIT_CARD',      'PENDING',   SYSDATE - 10, 15.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 37, 'BANK_TRANSFER',    'PENDING',   SYSDATE - 9,  18.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 38, 'CREDIT_CARD',      'PENDING',   SYSDATE - 9,  22.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 39, 'WALLET',           'PENDING',   SYSDATE - 8,  9.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 40, 'PAYPAL',           'PENDING',   SYSDATE - 8,  11.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 41, 'DEBIT_CARD',       'PENDING',   SYSDATE - 7,  7.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 42, 'CREDIT_CARD',      'PENDING',   SYSDATE - 7,  8.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 43, 'CASH_ON_DELIVERY', 'PENDING',   SYSDATE - 6,  21.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 44, 'CREDIT_CARD',      'PENDING',   SYSDATE - 6,  28.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 45, 'PAYPAL',           'PENDING',   SYSDATE - 5,  10.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 46, 'WALLET',           'PENDING',   SYSDATE - 5,  24.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 47, 'DEBIT_CARD',       'PENDING',   SYSDATE - 4,  69.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 48, 'CREDIT_CARD',      'PENDING',   SYSDATE - 4,  49.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 49, 'BANK_TRANSFER',    'PENDING',   SYSDATE - 3,  429.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 50, 'PAYPAL',           'PENDING',   SYSDATE - 3,  44.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 51, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 75, 349.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 52, 'DEBIT_CARD',       'COMPLETED', SYSDATE - 60, 1099.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 53, 'CASH_ON_DELIVERY', 'COMPLETED', SYSDATE - 50, 49.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 54, 'PAYPAL',           'COMPLETED', SYSDATE - 42, 34.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 55, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 35, 249.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 56, 'WALLET',           'COMPLETED', SYSDATE - 28, 149.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 57, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 22, 349.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 58, 'BANK_TRANSFER',    'PENDING',   SYSDATE - 16, 199.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 59, 'PAYPAL',           'PENDING',   SYSDATE - 10, 89.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 60, 'DEBIT_CARD',       'PENDING',   SYSDATE - 5,  34.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 61, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 70, 799.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 62, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 55, 679.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 63, 'PAYPAL',           'COMPLETED', SYSDATE - 44, 399.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 64, 'WALLET',           'COMPLETED', SYSDATE - 33, 99.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 65, 'DEBIT_CARD',       'PENDING',   SYSDATE - 21, 59.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 66, 'CREDIT_CARD',      'PENDING',   SYSDATE - 12, 149.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 67, 'CASH_ON_DELIVERY', 'PENDING',   SYSDATE - 6,  179.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 68, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 80, 1299.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 69, 'PAYPAL',           'COMPLETED', SYSDATE - 65, 1199.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 70, 'DEBIT_CARD',       'COMPLETED', SYSDATE - 50, 49.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 71, 'WALLET',           'COMPLETED', SYSDATE - 40, 59.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 72, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 30, 29.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 73, 'BANK_TRANSFER',    'PENDING',   SYSDATE - 20, 79.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 74, 'PAYPAL',           'PENDING',   SYSDATE - 10, 9.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 75, 'CASH_ON_DELIVERY', 'COMPLETED', SYSDATE - 75, 649.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 76, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 60, 449.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 77, 'DEBIT_CARD',       'PENDING',   SYSDATE - 45, 199.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 78, 'PAYPAL',           'PENDING',   SYSDATE - 30, 149.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 79, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 70, 429.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 80, 'BANK_TRANSFER',    'COMPLETED', SYSDATE - 55, 349.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 81, 'WALLET',           'PENDING',   SYSDATE - 40, 179.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 82, 'CREDIT_CARD',      'PENDING',   SYSDATE - 20, 99.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 83, 'PAYPAL',           'COMPLETED', SYSDATE - 60, 399.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 84, 'DEBIT_CARD',       'COMPLETED', SYSDATE - 45, 599.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 85, 'CREDIT_CARD',      'PENDING',   SYSDATE - 30, 249.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 86, 'CASH_ON_DELIVERY', 'PENDING',   SYSDATE - 15, 159.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 87, 'CREDIT_CARD',      'COMPLETED', SYSDATE - 85, 1099.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 88, 'PAYPAL',           'COMPLETED', SYSDATE - 70, 799.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 89, 'WALLET',           'COMPLETED', SYSDATE - 55, 349.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 90, 'DEBIT_CARD',       'PENDING',   SYSDATE - 40, 199.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 91, 'CREDIT_CARD',      'PENDING',   SYSDATE - 25, 149.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 92, 'BANK_TRANSFER',    'PENDING',   SYSDATE - 10, 79.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 93, 'PAYPAL',           'FAILED',    SYSDATE - 5,  44.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 94, 'CREDIT_CARD',      'FAILED',    SYSDATE - 3,  299.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 95, 'DEBIT_CARD',       'REFUNDED',  SYSDATE - 60, 59.99);
INSERT INTO payments VALUES (seq_payments.NEXTVAL, 96, 'CREDIT_CARD',      'REFUNDED',  SYSDATE - 45, 129.99);

-- ------------------------------------------------------------
-- SHIPMENTS
-- ------------------------------------------------------------

INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 1,  'TRK-PK-001-2024', 'TCS Courier',     'DELIVERED',         SYSDATE - 88, SYSDATE - 85);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 2,  'TRK-PK-002-2024', 'Leopards Courier', 'DELIVERED',         SYSDATE - 86, SYSDATE - 83);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 3,  'TRK-PK-003-2024', 'DHL Pakistan',     'DELIVERED',         SYSDATE - 83, SYSDATE - 80);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 4,  'TRK-PK-004-2024', 'FedEx',            'DELIVERED',         SYSDATE - 81, SYSDATE - 78);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 5,  'TRK-PK-005-2024', 'TCS Courier',      'DELIVERED',         SYSDATE - 78, SYSDATE - 75);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 6,  'TRK-PK-006-2024', 'PostEx',           'DELIVERED',         SYSDATE - 76, SYSDATE - 73);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 7,  'TRK-PK-007-2024', 'DHL Pakistan',     'DELIVERED',         SYSDATE - 73, SYSDATE - 70);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 8,  'TRK-PK-008-2024', 'Leopards Courier', 'DELIVERED',         SYSDATE - 71, SYSDATE - 68);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 9,  'TRK-PK-009-2024', 'TCS Courier',      'DELIVERED',         SYSDATE - 68, SYSDATE - 65);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 10, 'TRK-PK-010-2024', 'M&P Courier',      'DELIVERED',         SYSDATE - 66, SYSDATE - 63);

INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 11, 'TRK-PK-011-2024', 'TCS Courier',      'DELIVERED',         SYSDATE - 63, SYSDATE - 60);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 12, 'TRK-PK-012-2024', 'DHL Pakistan',     'DELIVERED',         SYSDATE - 61, SYSDATE - 58);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 13, 'TRK-PK-013-2024', 'FedEx',            'DELIVERED',         SYSDATE - 58, SYSDATE - 55);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 14, 'TRK-PK-014-2024', 'PostEx',           'DELIVERED',         SYSDATE - 56, SYSDATE - 53);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 15, 'TRK-PK-015-2024', 'Leopards Courier', 'DELIVERED',         SYSDATE - 53, SYSDATE - 50);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 16, 'TRK-PK-016-2024', 'TCS Courier',      'DELIVERED',         SYSDATE - 51, SYSDATE - 48);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 17, 'TRK-PK-017-2024', 'M&P Courier',      'DELIVERED',         SYSDATE - 48, SYSDATE - 45);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 18, 'TRK-PK-018-2024', 'DHL Pakistan',     'DELIVERED',         SYSDATE - 46, SYSDATE - 43);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 19, 'TRK-PK-019-2024', 'TCS Courier',      'DELIVERED',         SYSDATE - 43, SYSDATE - 40);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 20, 'TRK-PK-020-2024', 'FedEx',            'DELIVERED',         SYSDATE - 41, SYSDATE - 38);

INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 21, 'TRK-PK-021-2024', 'PostEx',           'IN_TRANSIT',        SYSDATE - 38, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 22, 'TRK-PK-022-2024', 'TCS Courier',      'IN_TRANSIT',        SYSDATE - 36, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 23, 'TRK-PK-023-2024', 'Leopards Courier', 'OUT_FOR_DELIVERY',  SYSDATE - 33, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 24, 'TRK-PK-024-2024', 'DHL Pakistan',     'OUT_FOR_DELIVERY',  SYSDATE - 31, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 25, 'TRK-PK-025-2024', 'TCS Courier',      'IN_TRANSIT',        SYSDATE - 28, NULL);

INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 26, 'TRK-PK-026-2024', 'M&P Courier',      'IN_TRANSIT',        SYSDATE - 26, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 27, 'TRK-PK-027-2024', 'FedEx',            'DISPATCHED',        SYSDATE - 23, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 28, 'TRK-PK-028-2024', 'PostEx',           'DISPATCHED',        SYSDATE - 21, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 29, 'TRK-PK-029-2024', 'TCS Courier',      'DISPATCHED',        SYSDATE - 18, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 30, 'TRK-PK-030-2024', 'DHL Pakistan',     'DISPATCHED',        SYSDATE - 16, NULL);

INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 31, 'TRK-PK-031-2024', 'Leopards Courier', 'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 32, 'TRK-PK-032-2024', 'TCS Courier',      'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 33, 'TRK-PK-033-2024', 'M&P Courier',      'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 34, 'TRK-PK-034-2024', 'PostEx',           'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 35, 'TRK-PK-035-2024', 'DHL Pakistan',     'PENDING',           NULL, NULL);

INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 36, 'TRK-PK-036-2024', 'FedEx',            'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 37, 'TRK-PK-037-2024', 'TCS Courier',      'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 38, 'TRK-PK-038-2024', 'Leopards Courier', 'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 39, 'TRK-PK-039-2024', 'PostEx',           'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 40, 'TRK-PK-040-2024', 'M&P Courier',      'PENDING',           NULL, NULL);

INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 41, 'TRK-PK-041-2024', 'TCS Courier',      'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 42, 'TRK-PK-042-2024', 'DHL Pakistan',     'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 43, 'TRK-PK-043-2024', 'FedEx',            'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 44, 'TRK-PK-044-2024', 'PostEx',           'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 45, 'TRK-PK-045-2024', 'Leopards Courier', 'PENDING',           NULL, NULL);

INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 46, 'TRK-PK-046-2024', 'TCS Courier',      'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 47, 'TRK-PK-047-2024', 'M&P Courier',      'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 48, 'TRK-PK-048-2024', 'DHL Pakistan',     'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 49, 'TRK-PK-049-2024', 'FedEx',            'PENDING',           NULL, NULL);
INSERT INTO shipments VALUES (seq_shipments.NEXTVAL, 50, 'TRK-PK-050-2024', 'TCS Courier',      'PENDING',           NULL, NULL);

COMMIT;

SELECT * FROM shipments;

-- ------------------------------------------------------------
-- ORDER_STATUS_HISTORY
-- ------------------------------------------------------------

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 1,  'PENDING',    SYSDATE - 90);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 1,  'CONFIRMED',  SYSDATE - 89);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 1,  'PROCESSING', SYSDATE - 89);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 1,  'SHIPPED',    SYSDATE - 88);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 1,  'DELIVERED',  SYSDATE - 85);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 2,  'PENDING',    SYSDATE - 88);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 2,  'CONFIRMED',  SYSDATE - 87);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 2,  'SHIPPED',    SYSDATE - 86);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 2,  'DELIVERED',  SYSDATE - 83);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 3,  'PENDING',    SYSDATE - 85);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 3,  'CONFIRMED',  SYSDATE - 84);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 3,  'SHIPPED',    SYSDATE - 83);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 3,  'DELIVERED',  SYSDATE - 80);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 4,  'PENDING',    SYSDATE - 83);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 4,  'CONFIRMED',  SYSDATE - 82);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 4,  'PROCESSING', SYSDATE - 82);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 4,  'SHIPPED',    SYSDATE - 81);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 4,  'DELIVERED',  SYSDATE - 78);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 5,  'PENDING',    SYSDATE - 80);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 5,  'CONFIRMED',  SYSDATE - 79);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 5,  'SHIPPED',    SYSDATE - 78);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 5,  'DELIVERED',  SYSDATE - 75);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 6,  'PENDING',    SYSDATE - 78);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 6,  'CONFIRMED',  SYSDATE - 77);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 6,  'SHIPPED',    SYSDATE - 76);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 6,  'DELIVERED',  SYSDATE - 73);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 7,  'PENDING',    SYSDATE - 75);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 7,  'CONFIRMED',  SYSDATE - 74);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 7,  'SHIPPED',    SYSDATE - 73);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 7,  'DELIVERED',  SYSDATE - 70);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 8,  'PENDING',    SYSDATE - 73);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 8,  'CONFIRMED',  SYSDATE - 72);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 8,  'SHIPPED',    SYSDATE - 71);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 8,  'DELIVERED',  SYSDATE - 68);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 9,  'PENDING',    SYSDATE - 70);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 9,  'CONFIRMED',  SYSDATE - 69);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 9,  'SHIPPED',    SYSDATE - 68);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 9,  'DELIVERED',  SYSDATE - 65);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 10, 'PENDING',    SYSDATE - 68);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 10, 'CONFIRMED',  SYSDATE - 67);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 10, 'SHIPPED',    SYSDATE - 66);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 10, 'DELIVERED',  SYSDATE - 63);

-- extra orders
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 21, 'PENDING',    SYSDATE - 40);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 21, 'CONFIRMED',  SYSDATE - 39);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 21, 'PROCESSING', SYSDATE - 39);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 21, 'SHIPPED',    SYSDATE - 38);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 22, 'PENDING',    SYSDATE - 38);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 22, 'CONFIRMED',  SYSDATE - 37);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 22, 'SHIPPED',    SYSDATE - 36);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 23, 'PENDING',    SYSDATE - 35);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 23, 'CONFIRMED',  SYSDATE - 34);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 23, 'SHIPPED',    SYSDATE - 33);

-- special cases
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 31, 'PENDING',    SYSDATE - 15);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 31, 'CONFIRMED',  SYSDATE - 14);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 31, 'PROCESSING', SYSDATE - 14);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 37, 'PENDING',    SYSDATE - 9);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 37, 'CONFIRMED',  SYSDATE - 8);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 43, 'PENDING',    SYSDATE - 6);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 44, 'PENDING',    SYSDATE - 6);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 45, 'PENDING',    SYSDATE - 5);

-- cancelled / returned / refunded cases
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 93, 'PENDING',    SYSDATE - 5);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 93, 'CONFIRMED',  SYSDATE - 5);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 93, 'CANCELLED',  SYSDATE - 4);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 94, 'PENDING',    SYSDATE - 3);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 94, 'CANCELLED',  SYSDATE - 2);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 95, 'PENDING',    SYSDATE - 62);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 95, 'CONFIRMED',  SYSDATE - 61);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 95, 'SHIPPED',    SYSDATE - 60);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 95, 'DELIVERED',  SYSDATE - 57);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 95, 'RETURNED',   SYSDATE - 53);

INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 96, 'PENDING',    SYSDATE - 47);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 96, 'CONFIRMED',  SYSDATE - 46);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 96, 'SHIPPED',    SYSDATE - 45);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 96, 'DELIVERED',  SYSDATE - 42);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 96, 'RETURNED',   SYSDATE - 39);
INSERT INTO order_status_history VALUES (seq_status_history.NEXTVAL, 96, 'REFUNDED',   SYSDATE - 36);

COMMIT;

SELECT * FROM order_status_history;

-- ------------------------------------------------------------
-- REVIEWS
-- ------------------------------------------------------------

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 1, 1, 5.0, 'Amazing phone! The camera quality is absolutely stunning. Worth every penny.', SYSDATE - 82);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 2, 2, 4.5, 'iPhone 15 Pro is incredible. A17 chip is blazing fast. Titanium feels premium.', SYSDATE - 80);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 3, 3, 5.0, 'Best noise-canceling headphones I have ever used. 30-hour battery is a game changer.', SYSDATE - 77);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 4, 4, 4.5, 'Dell XPS 15 is a powerhouse. OLED display is gorgeous. A bit heavy but worth it.', SYSDATE - 75);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 5, 5, 5.0, 'MacBook Air M2 is perfect for everyday use. Silent, fast, and beautiful design.', SYSDATE - 72);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 6,  6,  4.0, 'Echo Dot works great with Alexa. Sound is better than previous gen. Good value.', SYSDATE - 70);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 7,  7,  4.5, 'Samsung QLED TV picture quality is stunning. Smart TV features work seamlessly.', SYSDATE - 67);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 8,  8,  4.5, 'Canon EOS R50 is a fantastic entry-level mirrorless. 4K video looks professional.', SYSDATE - 65);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 9,  9,  5.0, 'Apple Watch Series 9 is the best smartwatch available. Health tracking is accurate.', SYSDATE - 62);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 10, 10, 4.0, 'Logitech MX Master 3S is ergonomic and responsive. Silent clicks are a great feature.', SYSDATE - 60);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 11, 11, 4.5, 'Classic Levi 501 jeans. Perfect fit and very durable. My go-to denim brand.', SYSDATE - 57);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 12, 12, 5.0, 'Nike Air Max 270 are so comfortable! Perfect for all-day wear. Love the style.', SYSDATE - 55);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 13, 13, 4.5, 'Adidas Ultraboost 22 are amazing running shoes. Boost technology is real.', SYSDATE - 52);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 14, 14, 4.0, 'Ralph Lauren polo quality is excellent. Fabric feels premium and breathable.', SYSDATE - 50);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 15, 15, 3.5, 'Zara dress is nice but runs small. Size up. Colors are vibrant though.', SYSDATE - 47);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 16, 16, 5.0, 'North Face Thermoball jacket is incredibly warm yet lightweight. Perfect for winter.', SYSDATE - 45);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 17, 17, 4.5, 'Ray-Ban Aviators are timeless. Great UV protection and build quality is solid.', SYSDATE - 42);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 18, 18, 4.0, 'Calvin Klein chinos fit perfectly. Stretch fabric makes them very comfortable.', SYSDATE - 40);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 19, 19, 3.0, 'Gucci belt looks authentic but the price is steep. Quality matches the price.', SYSDATE - 37);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 20, 20, 4.5, 'H&M cotton tees are soft and value for money. Great basics for everyday wear.', SYSDATE - 35);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 21, 21, 5.0, 'Instant Pot is a kitchen essential. Saves so much time. Easy to clean too.', SYSDATE - 32);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 22, 22, 5.0, 'Dyson V15 is worth every penny. Laser reveals how dirty floors really are!', SYSDATE - 30);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 23, 23, 4.5, 'KitchenAid mixer is a baking game changer. Powerful motor and beautiful design.', SYSDATE - 27);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 24, 24, 4.0, 'Philips Hue lights transform the ambiance. App control is intuitive and fun.', SYSDATE - 25);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 25, 25, 4.0, 'IKEA MALM bed frame is sturdy and easy to assemble. Modern minimalist design.', SYSDATE - 22);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 26, 26, 4.5, 'Ninja Air Fryer cooks everything perfectly. Crispy results with very little oil.', SYSDATE - 20);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 27, 27, 4.5, 'Calphalon cookware set is excellent. Non-stick coating is durable and even heating.', SYSDATE - 17);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 28, 28, 4.0, 'Tempur-Pedic pillow is comfortable but takes time to get used to the firmness.', SYSDATE - 15);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 29, 29, 5.0, 'Nespresso coffee tastes amazing. Fast and convenient for busy mornings.', SYSDATE - 12);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 30, 30, 4.5, 'LEVOIT air purifier noticeably improved air quality. Very quiet operation.', SYSDATE - 10);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 31, 31, 5.0, 'Atomic Habits changed my life. Practical advice that actually works. Must read.', SYSDATE - 82);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 32, 32, 5.0, 'Great Gatsby is timeless literature. Every page is beautifully written.', SYSDATE - 80);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 33, 33, 4.5, 'Sapiens is mind-blowing. Harari covers thousands of years in a digestible way.', SYSDATE - 77);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 34, 34, 5.0, 'Harry Potter box set is a treasure. Hardcover edition is gorgeous and perfect gift.', SYSDATE - 75);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 35, 35, 4.5, 'Clean Code is essential for every software developer. Changed how I write code.', SYSDATE - 72);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 36, 36, 5.0, 'The Alchemist is deeply moving. Read it three times and loved it more each time.', SYSDATE - 70);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 37, 37, 4.5, 'Thinking Fast and Slow is dense but rewarding. Kahneman explains biases brilliantly.', SYSDATE - 67);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 38, 38, 5.0, '1984 is haunting and more relevant than ever. Orwell was ahead of his time.', SYSDATE - 65);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 39, 39, 4.0, 'CLRS algorithms textbook is comprehensive. Essential for CS students and professionals.', SYSDATE - 62);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 40, 40, 4.0, 'Rich Dad Poor Dad gives a different perspective on money. Very motivating read.', SYSDATE - 60);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 41, 41, 5.0, 'CeraVe moisturizer is gentle and effective. Perfect for sensitive skin types.', SYSDATE - 57);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 42, 42, 4.5, 'Neutrogena Hydro Boost absorbs quickly. Skin feels hydrated all day long.', SYSDATE - 55);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 43, 43, 4.0, 'Maybelline foundation gives natural coverage. Great shade range for all skin tones.', SYSDATE - 52);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 44, 44, 3.5, 'LOreal shampoo smells great but I expected more hydration for the price.', SYSDATE - 50);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 45, 45, 5.0, 'The Ordinary Niacinamide serum visibly reduced my pores. Amazing results in 2 weeks.', SYSDATE - 47);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 46, 46, 4.5, 'Dove body wash leaves skin soft and moisturized. Great scent and value.', SYSDATE - 45);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 47, 47, 4.5, 'MAC Ruby Woo is the perfect red lip. Long lasting and intensely pigmented.', SYSDATE - 42);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 48, 48, 4.0, 'Olay Regenerist is a good anti-aging cream. Skin looks firmer after 4 weeks.', SYSDATE - 40);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 49, 49, 3.5, 'Pantene conditioner is decent. Hair is smoother but nothing extraordinary.', SYSDATE - 37);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 50, 50, 4.5, 'Gillette ProGlide gives the closest shave. Flexball handle works perfectly.', SYSDATE - 35);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 51, 51, 5.0, 'Wilson Evolution basketball has great grip and feels perfectly balanced.', SYSDATE - 32);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 52, 52, 4.0, 'Spalding NFL football is official quality. Great for backyard games.', SYSDATE - 30);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 53, 53, 5.0, 'Bowflex dumbbells replaced my entire weight rack. Compact and easy to adjust.', SYSDATE - 27);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 54, 54, 4.0, 'Peloton yoga mat is thick and non-slip. Perfect for hot yoga sessions.', SYSDATE - 25);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 55, 55, 4.5, 'Garmin Forerunner 255 tracks everything accurately. Battery lasts 10 days.', SYSDATE - 22);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 56, 56, 4.0, 'Callaway golf set is great for beginners. Bag is sturdy and clubs balanced.', SYSDATE - 20);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 57, 57, 4.5, 'Coleman tent is easy to set up and weatherproof. Great family camping gear.', SYSDATE - 17);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 58, 58, 5.0, 'Schwinn IC4 bike is incredible value. Smooth ride and Bluetooth works perfectly.', SYSDATE - 15);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 59, 59, 3.5, 'Head tennis racket is good for beginners. Serious players might want an upgrade.', SYSDATE - 12);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 60, 60, 4.5, 'TRX suspension trainer gave me a full body workout at home. Very versatile.', SYSDATE - 10);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 61, 61, 5.0, 'LEGO Technic Bugatti is an engineering masterpiece. Took 12 hours to build. Amazing.', SYSDATE - 82);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 62, 62, 4.5, 'Barbie Dreamhouse is every little girl dream. My daughter absolutely loves it.', SYSDATE - 80);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 63, 63, 4.0, 'Nerf Commander is fun for the whole family. Good range and easy to reload.', SYSDATE - 77);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 64, 64, 5.0, 'Fisher-Price learning toy is perfect for toddlers. Educational and entertaining.', SYSDATE - 75);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 65, 65, 4.5, 'Hot Wheels Ultimate Garage keeps my son entertained for hours. Great build quality.', SYSDATE - 72);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 66, 66, 5.0, 'Monopoly is a classic. Our family game nights are so much fun with this.', SYSDATE - 70);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 67, 67, 4.0, 'Play-Doh set is a great creative outlet for kids. Colors are vibrant.', SYSDATE - 67);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 68, 68, 4.5, 'Melissa and Doug puzzles are durable and age-appropriate. My toddler loves them.', SYSDATE - 65);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 69, 69, 4.0, 'RC Monster Truck is fast and handles well on rough terrain. Great gift for kids.', SYSDATE - 62);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 70, 70, 5.0, 'UNO is a must-have card game. Simple rules but endless fun for all ages.', SYSDATE - 60);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 71, 71, 4.0, 'Quaker oats are wholesome and filling. Quick to prepare and taste great.', SYSDATE - 57);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 72, 72, 3.5, 'Coffee-Mate is a convenient creamer but slightly artificial taste compared to fresh.', SYSDATE - 55);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 73, 73, 4.5, 'Heinz ketchup is the gold standard. No other brand compares to the taste.', SYSDATE - 52);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 74, 74, 5.0, 'Best basmati rice I have ever cooked. Grains are long, aromatic and fluffy.', SYSDATE - 50);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 75, 75, 4.0, 'Tropicana OJ tastes fresh and natural. Great vitamin C boost every morning.', SYSDATE - 47);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 76, 76, 4.5, 'Oreos are irresistible. Family size is excellent value. My kids go crazy for them.', SYSDATE - 45);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 77, 77, 5.0, 'This olive oil is exceptional quality. Rich taste that elevates every dish.', SYSDATE - 42);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 78, 78, 4.5, 'Lipton tea is consistently good. Strong flavor and pairs well with milk.', SYSDATE - 40);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 79, 79, 3.5, 'Corn Flakes are fine for a basic breakfast but nothing special taste-wise.', SYSDATE - 37);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 80, 80, 4.5, 'Skippy peanut butter is creamy and delicious. Perfect on toast or in smoothies.', SYSDATE - 35);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 81, 81, 4.0, 'Bosch tire gauge is accurate and easy to read. Great build quality for the price.', SYSDATE - 32);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 82, 82, 4.0, 'Armor All kit cleans everything well. Dashboard looks brand new after using it.', SYSDATE - 30);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 83, 83, 5.0, 'BlackVue dash cam 4K footage is crystal clear. Cloud feature is excellent.', SYSDATE - 27);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 84, 84, 4.5, 'Michelin jumper cables are heavy duty. Saved me twice already in winter.', SYSDATE - 25);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 85, 85, 4.5, 'Anker car charger is fast and reliable. Both ports deliver full power.', SYSDATE - 22);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 86, 86, 4.5, 'WeatherTech floor liners are a perfect fit. Car interior stays spotless.', SYSDATE - 20);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 87, 87, 4.0, 'Chemical Guys kit has everything needed for a professional detail job.', SYSDATE - 17);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 88, 88, 4.5, 'DEWALT jump starter is powerful. Jumped my dead battery in seconds flat.', SYSDATE - 15);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 89, 89, 4.5, 'Garmin GPS is very accurate and the 7-inch display is easy to see while driving.', SYSDATE - 12);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 90, 90, 4.0, 'Thule bike rack is sturdy and the anti-sway cradles work great on highways.', SYSDATE - 10);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 91, 91, 5.0, 'ON Gold Standard whey mixes well and tastes amazing. Best protein on the market.', SYSDATE - 82);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 92, 92, 4.5, 'Nature Made Vitamin D3 is easy to swallow. Noticed more energy after a month.', SYSDATE - 80);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 93, 93, 5.0, 'Omron BP monitor is very accurate. Matches clinic readings exactly. Highly recommend.', SYSDATE - 77);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 94, 94, 4.0, 'Garden of Life multivitamin feels premium. Whole food approach is worth the price.', SYSDATE - 75);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 95, 95, 4.5, 'Fitbit Charge 6 sleep tracking is excellent. GPS is accurate for outdoor runs.', SYSDATE - 72);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 96, 96, 4.0, 'Centrum Silver covers all bases. Easy to take and no unpleasant aftertaste.', SYSDATE - 70);

INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 97, 97, 4.5, 'Vicks VapoRub is a household staple. Instant relief for congestion and cough.', SYSDATE - 67);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 98, 98, 4.5, 'Nordic Naturals omega-3 has no fishy aftertaste. Lemon flavor is refreshing.', SYSDATE - 65);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 99, 99, 5.0, 'Infrared thermometer gives instant accurate readings. Perfect for family with kids.', SYSDATE - 62);
INSERT INTO reviews VALUES (seq_reviews.NEXTVAL, 100, 100, 4.0, 'MusclePharm protein bars taste great and keep me full. Good macros for post-workout.', SYSDATE - 60);

COMMIT;

SELECT * FROM reviews;

SELECT * FROM cart_items WHERE product_id NOT IN (SELECT product_id FROM products);
SELECT * FROM orders WHERE user_id NOT IN (SELECT user_id FROM users);