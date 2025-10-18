from fastapi import APIRouter

router = APIRouter(prefix="/product", tags=["products"])

@router.get("/{product_id}")
async def product(product_id: str):
    print(product_id)
    return {
        "message": "Product found"
    }