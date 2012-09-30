$(document).ready( function() {
	$('.see_more').on('click', function() {
		var book_id = $(this).data('book-id');
		var url = 'http://'+document.location.host+'/books/'+book_id;
		$book_info = $('.book_info[data-book_id="'+book_id+'"]')
		
		$('.book_info').hide();
		
		var add_book_info = function(template) {
			$book_info.html(template);
		};
		
		$.ajax({
			url: url,
			type: 'GET',
			dataType: 'html',
			success: function(template) {
				add_book_info(template);
			}
		});
		
		$book_info.show();
	});
});