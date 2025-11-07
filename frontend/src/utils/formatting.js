function baseFormatCurrency(amount, nullValue, formatterOptions = {}) {
  if (amount === null || amount === undefined) return nullValue;
  const baseOptions = {
    style: 'currency',
    currency: 'USD',
  };

  const finalOptions = { ...baseOptions, ...formatterOptions };
  return new Intl.NumberFormat('en-US', finalOptions).format(amount);
}

export function formatCurrency(amount) {
  return baseFormatCurrency(amount, 'N/A');
}

export function formatProductCardPrice(amount) {
  const options = {
    maximumFractionDigits: 0
  };
  return baseFormatCurrency(amount, '---', options);
}

export function formatDate(dateString) {
  if (!dateString) return 'N/A';
  const options = { year: 'numeric', month: 'long', day: 'numeric' };
  const date = new Date(dateString);
  date.setDate(date.getDate() + 1);
  return date.toLocaleDateString('en-US', options);
}
