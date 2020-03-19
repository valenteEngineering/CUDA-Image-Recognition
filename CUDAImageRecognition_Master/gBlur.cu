#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>

using namespace cv;
using namespace std;

int main( int argc, char** argv )
{
    if( argc != 2)
    {
     cout <<" Usage: display_image ImageToLoadAndDisplay" << endl;
     return -1;
    }

    Mat image;
    image = imread(argv[1], CV_LOAD_IMAGE_COLOR);   // Read the file

    if(! image.data )                              // Check for invalid input
    {
        cout <<  "Could not open or find the image" << std::endl ;
        return -1;
    }
    
    Mat blurredImage = image.clone();
	
	/* gaussian blur 3x3 kernel approximation */
    for(int i = 1; i < image.rows - 1; i++) {
        for(int j = 1; j < image.cols - 1; j++) { 
			for(int k = 0; k < 3; k++) {
				int total  = (1*(int)image.at<Vec3b>(i-1,j-1)[k] +
					2*(int)image.at<Vec3b>(i,j-1)[k] +
					1*(int)image.at<Vec3b>(i+1,j-1)[k] +
					2*(int)image.at<Vec3b>(i-1,j)[k] + 
					4*(int)image.at<Vec3b>(i,j)[k] + 
					2*(int)image.at<Vec3b>(i+1,j)[k] + 
					1*(int)image.at<Vec3b>(i-1,j+1)[k] +
					2*(int)image.at<Vec3b>(i,j+1)[k] + 
					1*(int)image.at<Vec3b>(i+1,j+1)[k]);
				blurredImage.at<Vec3b>(i,j)[k] = total/16;					
			}		
		}    
	}
	
	// openCV gaussian blur function
    // GaussianBlur(image, blurredImage, Size(9,9), 0, 0);
	
    namedWindow( "Display window", WINDOW_AUTOSIZE );     // Create a window for display.
    imshow( "Display window", blurredImage );             // Show our image inside it.

    waitKey(0);                                          // Wait for a keystroke in the window
    return 0;
}
