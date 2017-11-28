var Customer = function(){
  var self = this;

  self.init = function(){

    $("#GetCustomer").click(function(){
      window.location.assign("/customers/"+$("#Mobile").val());
    })
  }


}

$(document).ready(function(){
  if($(".customer-page").length != 0){
    var v = new Customer();
    v.init();    
  }
})