<?php
system('cp /Users/gauravk92/Desktop/foreground.png /Users/gauravk92/Desktop/output.png');
$fgImg = new Imagick('/Users/gauravk92/Desktop/output.png');
$bgImg = new Imagick('/Users/gauravk92/Desktop/background.png');

$width = $fgImg->getImageWidth();
$height = $fgImg->getImageHeight();
if($height != $bgImg->getImageHeight())
	return;

$fgImg->SetImageMatte(true);

$it = $fgImg->getPixelIterator();

foreach($it as $y => $pixels){
	$origPixel = $bgImg->getImagePixelColor(0, $y)->getColor();
	foreach ($pixels as $x => $pixel){
		$resultPixel = $pixel->getColor();
		//print_r($resultPixel);
		$oR = ((int)$resultPixel['r'] - (int)$origPixel['r'])/(255 - (int)$origPixel['r']);
		if($oR < 0) {
			$oR = ((int)$resultPixel['r'] - (int)$origPixel['r'])/(0 - (int)$origPixel['r']);
			$pixel->setColor("rgba(0,0,0,".$oR.")");
			print($x.",".$y."  :  black:".($oR)."\n");
		} else {
			$pixel->setColor("rgba(255,255,255,".$oR.")");
			print($x.",".$y."  :  white:".abs($oR)."\n");
		}

		$it->syncIterator();
	}

}

$fgImg->writeImage();


?>