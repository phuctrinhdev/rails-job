(function($) {
  $(window).scroll(function () {
    var scroll = $(window).scrollTop();
    if (scroll >= 1000) {
      $(".back2top").addClass("active");
    } else {
      $(".back2top").removeClass("active");
    }
  });
  $(".back2top").click(function(){
    $("html, body").animate({scrollTop: 0}, 500);
  })
  $(".apply-or-favorite-jobs").click(function (e) {
    e.preventDefault()
    data = { 
      job_ids: [$(this).data("id")],
      type: $(this).data("type")
    }
    $.ajax({
      url: '/apply_or_favorite',
      data: data,
      type: 'POST',
      success: (res) => {
        alert(res.message)
      },
      error: (err) => {
        if(err.status === 401){
          if(confirm(err.responseText)){
            window.location.href = "/users/sign_in";
          }
        }
      }
    });
  })
  $(".apply-all-job").click(function (e) {
    e.preventDefault()
    if($(".checkbox-apply-job:checked").length === 0){
      alert("Please choose jobs need apply!")
      return;
    }
    data = { 
      job_ids: [],
      type: 'apply'
    }
    $(".checkbox-apply-job:checked").each(function() {
      data.job_ids.push($(this).data("id"))
    })
    $.ajax({
      url: '/apply_or_favorite',
      data: data,
      type: 'POST',
      success: (res) => {
        alert(res.message)
        location.reload()
      },
      error: (err) => {
        if(err.status === 401){
          if(confirm(err.responseText)){
            window.location.href = "/users/sign_in";
          }
        }
      }
    });
  })
  $(".remove-favorite-job").click(function (e) {
    e.preventDefault()
    if(confirm("Are you sure?")){
      data = {
        favorite_id: $(this).data("favorite_id")
      }
      $.ajax({
        url: '/remove_favorite_job',
        data: data,
        type: 'DELETE',
        success: (res) => {
         alert(res.message)
         location.reload()
        },
        error: (err) => {
          if(err.status === 401){
            if(confirm(err.responseText)){
              window.location.href = "/users/sign_in";
            }
          }
        }
      });
    }
  })
})(jQuery);