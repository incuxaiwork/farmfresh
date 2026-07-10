import { Injectable } from '@nestjs/common';

export interface OrderCalculatedPricing {
  subtotal: number;
  discount: number;
  tax: number;
  deliveryFee: number;
  total: number;
}

@Injectable()
export class OrderPricingService {
  private readonly TAX_RATE = 0.05;
  private readonly DELIVERY_FLAT_FEE = 5.00;
  private readonly FREE_DELIVERY_THRESHOLD = 30.00;

  calculate(items: Array<{ quantity: number; price: number; discountPrice?: number | null }>): OrderCalculatedPricing {
    let subtotal = 0;
    let discount = 0;

    for (const item of items) {
      const itemPrice = item.price;
      subtotal += itemPrice * item.quantity;

      if (item.discountPrice !== undefined && item.discountPrice !== null) {
        discount += (itemPrice - item.discountPrice) * item.quantity;
      }
    }

    const taxableAmount = Math.max(0, subtotal - discount);
    const tax = Math.round((taxableAmount * this.TAX_RATE) * 100) / 100;
    const deliveryFee = (taxableAmount >= this.FREE_DELIVERY_THRESHOLD || subtotal === 0) 
      ? 0.00 
      : this.DELIVERY_FLAT_FEE;

    const total = Math.max(0, taxableAmount + tax + deliveryFee);

    return {
      subtotal: Math.round(subtotal * 100) / 100,
      discount: Math.round(discount * 100) / 100,
      tax: Math.round(tax * 100) / 100,
      deliveryFee: Math.round(deliveryFee * 100) / 100,
      total: Math.round(total * 100) / 100,
    };
  }
}
