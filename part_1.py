#MY APPROACH:
from sqlalchemy.exc import IntegrityError
from flask import request, jsonify

@app.route('/api/products', methods=['POST'])
def create_product():
    data = request.get_json() or {}
#issue 2 solve
    if 'name' not in data or 'sku' not in data or 'price' not in data:
        return jsonify({"error": "name, sku and price are required"}), 400
    
#issue 5 solve
    try:
        price = Decimal(str(data["price"]))
    except InvalidOperation:
        return jsonify({"error": "Invalid price format"}), 400

    try:
        product = Product(
            name=data['name'],
            sku=data['sku'],
            price=data['price']
        )
        db.session.add(product)
        db.session.flush()   #issue 1 solve

#issue 3 solve
        if 'warehouse_id' in data:
            inventory = Inventory(
                product_id=product.id,
                warehouse_id=data['warehouse_id'],
                quantity=data.get('initial_quantity', 0)
            )
            db.session.add(inventory)
        db.session.commit()

#issue 4 solve
    except IntegrityError:
        db.session.rollback()
        return jsonify({"error": "SKU must be unique"}), 409

    except Exception:
        db.session.rollback()
        return jsonify({"error": "Internal server error"}), 500

    return jsonify({
        "message": "Product created",
        "product_id": product.id
    }), 201
