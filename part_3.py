from fastapi import FastAPI
from datetime import datetime, timedelta

app = FastAPI()


@app.get("/api/companies/{company_id}/alerts/low-stock")
def low_stock_alerts(company_id: int):

    alerts = []

    # use warehouses of company
    warehouses = (
        db.query(Warehouse)
        .filter(Warehouse.company_id == company_id)
        .all()
    )

    if not warehouses:
        return {"alerts": [], "total_alerts": 0}

    # take inventory of each warehouse
    for w in warehouses:
        inventory_rows = (
            db.query(Inventory)
            .filter(Inventory.warehouse_id == w.id)
            .all()
        )

        for inv in inventory_rows:

            product = (
                db.query(Product)
                .filter(Product.id == inv.product_id)
                .first()
            )

            if not product:
                continue

            # threshold set
            threshold = (
                db.query(ProductThreshold)
                .filter(ProductThreshold.product_id == product.id)
                .first()
            )

            if not threshold:
                continue

            # count recent 30 days sales
            last_30 = datetime.utcnow() - timedelta(days=30)

            recent_sales = (
                db.query(Sale)
                .filter(
                    Sale.product_id == product.id,
                    Sale.warehouse_id == w.id,
                    Sale.created_at >= last_30
                )
                .count()
            )

            # if no sales then no alert
            if recent_sales == 0:
                continue

            # if stock < threshold then alert
            if inv.quantity < threshold.threshold:

                supplier = (
                    db.query(Supplier)
                    .join(
                        ProductSupplier,
                        ProductSupplier.supplier_id == Supplier.id
                    )
                    .filter(ProductSupplier.product_id == product.id)
                    .first()
                )

                alerts.append({
                    "product_id": product.id,
                    "product_name": product.name,
                    "sku": product.sku,
                    "warehouse_id": w.id,
                    "warehouse_name": w.name,
                    "current_stock": inv.quantity,
                    "threshold": threshold.threshold,
                    "days_until_stockout": None,
                    "supplier": {
                        "id": supplier.id if supplier else None,
                        "name": supplier.name if supplier else None,
                        "contact_email": supplier.contact_email if supplier else None
                    }
                })

    return {
        "alerts": alerts,
        "total_alerts": len(alerts)
    }
