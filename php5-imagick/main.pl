#!/usr/local/bin/perl

use strict;
use warnings;
use Image::Magick;

my($image, $x);

$image = Image::Magick->new;
$x = $image->Read('foreground.png');
warn "$x" if "$x";

my $fgImg = $image->Clone();

my $bgImg = Image::Magick->new;
$x = $bgImg->Read('background.png');
warn "$x" if "$x";

my ($width, $height) = $fgImg->Get('width', 'height');
# if ($height != $bgImg->getImageHeight()) {
# 	print "ERROR: INCOMPATIBLE SIZE\n";
# 	exit;
# }

# $fgImg->SetImageMatte(true);

my $it = $fgImg->getPixelIterator();

for (my $fgH = 0; $fgH < $height; $fgH++ ) {
	for (my $fgW = 0; $fgW < $width; $fgW++) {
		my @bgPixel = $bgImg->GetPixel( x => $fgW, y => $fgH);
		my @fgPixel = $fgImg->GetPixel( x => $fgW, y => $fgH);

		print @fgPixel;
	}
}

# use strict;
# 16	use Image::Magick;
# 17
# 18	# read original image
# 19	my $orig = Image::Magick->new();
# 20	my $w = $orig->Read('rose:');
# 21	warn("$w")  if $w;
# 22	exit  if $w =~ /^Exception/;
# 23
# 24
# 25	# make a clone of the image for modifications
# 26	my $dest = $orig->Clone();
# 27
# 28	# You could enlarge destination image here if you like.
# 29	# And it is posible to modify the existing image directly
# 30	# rather than modifying a clone as FX does.
# 31
# 32	# Iterate over destination image...
# 33	my ($width, $height) = $dest->Get('width', 'height');
# 34
# 35	for( my $j = 0; $j < $height; $j++ ) {
# 36	  for( my $i = 0; $i < $width; $i++ ) {
# 37
# 38	    # read original image color
# 39	    my @pixel = $orig->GetPixel( x=>$i, y=>$j );
# 40
# 41	    # modify the pixel values (as normalized floats)
# 42	    $pixel[0] = $pixel[0]/2;      # darken red
# 43
# 44	    # write pixel to destination
# 45	    # (quantization and clipping happens here)
# 46	    $dest->SetPixel(x=>$i,y=>$j,color=>\@pixel);
# 47	  }
# 48	}
# 49
# 50	# display the result (or you could save it)
# 51	$dest->Write('win:');
# 52	$dest->Write('pixel_fx.gif');

# $x = $image->Crop(geometry=>'100x100+100+100');
# warn "$x" if "$x";

# $x = $image->Write();
# warn "$x" if "$x";

# system('cp /Users/gauravk92/Desktop/foreground.png /Users/gauravk92/Desktop/output.png');
# $fgImg = new Imagick('/Users/gauravk92/Desktop/output.png');
# $bgImg = new Imagick('/Users/gauravk92/Desktop/background.png');

# $width = $fgImg->getImageWidth();
# $height = $fgImg->getImageHeight();
# if($height != $bgImg->getImageHeight())
# 	return;

# $fgImg->SetImageMatte(true);

# $it = $fgImg->getPixelIterator();

# foreach($it as $y => $pixels){
# 	$origPixel = $bgImg->getImagePixelColor(0, $y)->getColor();
# 	foreach ($pixels as $x => $pixel){
# 		$resultPixel = $pixel->getColor();
# 		//print_r($resultPixel);
# 		$oR = ((int)$resultPixel['r'] - (int)$origPixel['r'])/(255 - (int)$origPixel['r']);
# 		if($oR < 0) {
# 			$oR = ((int)$resultPixel['r'] - (int)$origPixel['r'])/(0 - (int)$origPixel['r']);
# 			$pixel->setColor("rgba(0,0,0,".$oR.")");
# 			print($x.",".$y."  :  black:".($oR)."\n");
# 		} else {
# 			$pixel->setColor("rgba(255,255,255,".$oR.")");
# 			print($x.",".$y."  :  white:".abs($oR)."\n");
# 		}

# 		$it->syncIterator();
# 	}

# }

# $fgImg->writeImage();
