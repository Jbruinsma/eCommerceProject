import { fetchFromAPI } from '@/utils/api.js'

export async function getBuyerFee(){
  return await fetchFromAPI('/fees/buyer_fee_percentage')
}

export async function getSellerFee(){
  return await fetchFromAPI('/fees/seller_fee_percentage')
}
