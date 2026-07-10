import { Injectable } from '@nestjs/common';

export interface CalculatedPricing {
  subtotal: number;
  discount: number;
  tax: number;
  deliveryCharge: number;
  grandTotal: number;
}

@Injectable()
export class PricingService {
  private readonly TAX_RATE = 0.05; // 5% VAT tax rate
  private readonly DELIVERY_FLAT_FEE = 5.00;
  private readonly FREE_DELIVERY_THRESHOLD = 30.00;

  calculate(items: Array<{ quantity: number; unitPrice: number; discountPrice?: number | null }>): CalculatedPricing {
    let subtotal = 0;
    let discount = 0;

    for (const item of items) {
      const itemPrice = item.unitPrice;
      const itemSubtotal = itemPrice * item.quantity;
      subtotal += itemSubtotal;

      if (item.discountPrice !== undefined && item.discountPrice !== null) {
        const itemDiscount = (itemPrice - item.discountPrice) * item.quantity;
        discount += itemDiscount;
      }
    }

    // Apply tax on discounted subtotal
    const taxableAmount = Math.max(0, subtotal - discount);
    const tax = Math.round((taxableAmount * this.TAX_RATE) * 100) / 100;

    // Calculate delivery charge
    const deliveryCharge = (taxableAmount >= this.FREE_DELIVERY_THRESHOLD || subtotal === 0) 
      ? 0.00 
      : this.DELIVERY_FLAT_FEE;

    const grandTotal = Math.max(0, taxableAmount + tax + deliveryCharge);

    return {
      subtotal: Math.round(subtotal * 100) / 100,
      discount: Math.round(discount * 100) / 100,
      tax: Math.round(tax * 100) / 100,
      deliveryCharge: Math.round(deliveryCharge * 100) / 100,
      grandTotal: Math.round(grandTotal * 100) / 100,
    };
  }
}
