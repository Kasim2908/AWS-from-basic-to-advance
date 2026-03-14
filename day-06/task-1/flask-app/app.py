from flask import Flask, jsonify, request
import pymysql
import os

app = Flask(__name__)

DB_CONFIG = {
    'host': os.environ.get('RDS_HOST'),
    'user': os.environ.get('RDS_USER'),
    'password': os.environ.get('RDS_PASSWORD'),
    'database': os.environ.get('RDS_DB', 'ecommerce')
}

def get_db():
    return pymysql.connect(**DB_CONFIG)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/')
def index():
    return jsonify({'message': 'Flask App on ECS + ECR', 'version': '2.0'}), 200

@app.route('/products', methods=['GET'])
def get_products():
    conn = get_db()
    with conn.cursor(pymysql.cursors.DictCursor) as cursor:
        cursor.execute("SELECT * FROM products")
        products = cursor.fetchall()
    conn.close()
    return jsonify(products), 200

@app.route('/products', methods=['POST'])
def add_product():
    data = request.json
    conn = get_db()
    with conn.cursor() as cursor:
        cursor.execute("INSERT INTO products (name, price, stock) VALUES (%s, %s, %s)",
                      (data['name'], data['price'], data['stock']))
    conn.commit()
    conn.close()
    return jsonify({'message': 'Product added'}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
