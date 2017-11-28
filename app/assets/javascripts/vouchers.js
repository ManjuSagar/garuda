var Voucher = function(){
  var self = this;

  self.init = function(){

    $("#GetVoucher").click(function(){
      window.location.assign("/vouchers/"+$("#VoucherId").val());
    })
  }


}


$(document).ready(function(){
  if($(".voucher-page").length != 0){
    var v = new Voucher();
    v.init();    
  }
})