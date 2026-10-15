export async function initiatePayment(req, res) {
  try {
    const { rideId, amount, paymentMethod, phoneNumber } = req.body;

    if (!amount || !paymentMethod) {
      return res.status(400).json({ success: false, message: 'Kiasi na njia ya malipo vinahitajika' });
    }

    const transactionId = `TXN-${Date.now()}`;

    if (paymentMethod === 'cash') {
      return res.json({
        success: true,
        transactionId,
        paymentMethod: 'cash',
        amount,
        status: 'pending_cash_collection',
        message: 'Mteja atalipa pesa taslimu (Cash) safari itakapokamilika.'
      });
    }

    // Mobile Money (M-Pesa / Tigo Pesa / Airtel Money)
    console.log(`💳 [Mobile Payment] Initiating ${paymentMethod} STK Push for TZS ${amount} to ${phoneNumber}`);

    res.json({
      success: true,
      transactionId,
      paymentMethod,
      amount,
      status: 'pending_stk_push',
      message: `Ombi la malipo (USSD Push) limetumwa kwenye namba ${phoneNumber}. Mteja aweke PIN kuthibitisha.`,
      checkoutUrl: undefined
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function paymentCallback(req, res) {
  try {
    console.log('📲 [Payment Callback Received]:', req.body);
    // Process M-Pesa / Aggregator callback webhook
    res.json({ result: 'OK' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function getWalletBalance(req, res) {
  try {
    res.json({
      success: true,
      currency: 'TZS',
      mainWallet: 25000,
      fuelWallet: 14500,
      recentTransactions: [
        { id: 'TXN-1', type: 'credit', title: 'Top-up via M-Pesa', amount: 30000, date: '2026-10-14' },
        { id: 'TXN-2', type: 'debit', title: 'Malipo ya Safari TRIP-8841', amount: 5000, date: '2026-10-14' }
      ]
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

export async function topupWallet(req, res) {
  try {
    const { amount, paymentMethod, phoneNumber } = req.body;

    res.json({
      success: true,
      transactionId: `TOPUP-${Date.now()}`,
      message: `Ombi la kuongeza TZS ${amount} limetumwa kwa namba ${phoneNumber}.`,
      status: 'pending_confirmation'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}
