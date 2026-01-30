function paystackPopUp(publicKey, email, amount, ref, onClosed, onSuccess) {
  let handler = PaystackPop.setup({
    key: publicKey,
    email: email,
    amount: amount,
    ref: ref,
    onClose: function () {
      onClosed();
    },
    callback: function (response) {
      onSuccess();
    },
  });
  handler.openIframe();
}
