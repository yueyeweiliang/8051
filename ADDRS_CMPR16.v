module ADDRS_CMPR16 (A, B, EN, EQ);

input 	[15:0] A;
input 	[15:0] B;
input		   EN;
output		   EQ;

wire EQ;

assign EQ = EN &
		   ~(A[15] ^ B[15])  &
		   ~(A[14] ^ B[14])  &
		   ~(A[13] ^ B[13])  &
		   ~(A[12] ^ B[12])  &
		   ~(A[11] ^ B[11])  &
		   ~(A[10] ^ B[10])  &
		   ~(A[9]  ^ B[9] )  &
		   ~(A[8]  ^ B[8] )  &
		   ~(A[7]  ^ B[7] )  &
		   ~(A[6]  ^ B[6] )  &
		   ~(A[5]  ^ B[5] )  &
		   ~(A[4]  ^ B[4] )  &
		   ~(A[3]  ^ B[3] )  &
		   ~(A[2]  ^ B[2] )  &
		   ~(A[1]  ^ B[1] )  &
		   ~(A[0]  ^ B[0] ) ;

endmodule // ADDRS_CMPR16


