from pydantic import BaseModel

from datetime import date


class PortfolioItem(BaseModel):
    # {
    #     portfolio_item_id: 1,
    #     product: {product_id: 1, name: 'Dunk Low "Panda"',
    #               image_url: 'https://placehold.co/100x100/1a1a1a/ffffff?text=Dunk'},
    #     size: {size_id: 13, size_value: '10'},
    #     acquisition_date: '2023-05-15',
    #     acquisition_price: 110.00,
    #     market_value: 155.00,
    #     gain_loss: 45.00
    # }
    portfolioItemId: str
    product: dict
    size: dict
    acquisitionDate: date | None
    acquisitionPrice: int
    marketValue: float | None
    gainLoss: float | None