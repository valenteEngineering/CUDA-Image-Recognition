source /usr/usc/cuda/default/setup.sh
source /usr/usc/opencv/default/setup.sh
nvcc -O3 gBlur.cu -I/usr/usc/opencv/default/include -lopencv_core -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc -L/usr/usc/opencv/default/lib -o gBlurOutput