$dashboardContainer = $('.offer-masonry');
$dashboardContainer.imagesLoaded ->
  $dashboardContainer.masonry {
    itemSelector : '.offer-box',
    columnWidth: ( containerWidth ) ->
      return containerWidth / 4

  }

$bidsContainer = $('.bid-masonry');
$bidsContainer.imagesLoaded ->
  $bidsContainer.masonry {
    itemSelector : '.bid-box',
    columnWidth: ( containerWidth ) ->
      return containerWidth / 4

  }
