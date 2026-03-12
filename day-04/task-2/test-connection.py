import pymysql
import os

# RDS Configuration
RDS_HOST = os.environ.get('RDS_HOST', 'ecommerce-db.xxxxxxxxx.us-east-1.rds.amazonaws.com')
RDS_USER = os.environ.get('RDS_USER', 'admin')
RDS_PASSWORD = os.environ.get('RDS_PASSWORD', 'your-password')
RDS_DB = os.environ.get('RDS_DB', 'ecommerce')

def get_connection():
    return pymysql.connect(
        host=RDS_HOST,
        user=RDS_USER,
        password=RDS_PASSWORD,
        database=RDS_DB,
        connect_timeout=5
    )

def create_table():
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS products (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                price DECIMAL(10, 2) NOT NULL,
                stock INT DEFAULT 0
            )
        """)
    conn.commit()
    conn.close()
    print("✅ Table created")

def insert_product(name, price, stock):
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute("INSERT INTO products (name, price, stock) VALUES (%s, %s, %s)", 
                      (name, price, stock))
    conn.commit()
    conn.close()
    print(f"✅ Inserted: {name}")

def read_products():
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM products")
        results = cursor.fetchall()
    conn.close()
    print("📦 Products:", results)
    return results

def update_product(product_id, stock):
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute("UPDATE products SET stock = %s WHERE id = %s", (stock, product_id))
    conn.commit()
    conn.close()
    print(f"✅ Updated product {product_id}")

def delete_product(product_id):
    conn = get_connection()
    with conn.cursor() as cursor:
        cursor.execute("DELETE FROM products WHERE id = %s", (product_id,))
    conn.commit()
    conn.close()
    print(f"✅ Deleted product {product_id}")

if __name__ == "__main__":
    try:
        print("🔗 Testing RDS Connection...")
        create_table()
        insert_product("Laptop", 999.99, 10)
        insert_product("Mouse", 29.99, 50)
        read_products()
        update_product(1, 8)
        read_products()
        print("✅ All CRUD operations successful!")
    except Exception as e:
        print(f"❌ Error: {e}")
