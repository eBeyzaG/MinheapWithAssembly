# MinheapWithAssembly
Implementation of MinHeap data structure with ARM Assembly Language

# Summary
In this Project, MinHeap data structure is implemented in ARM assembly language. Minheap is a data structure where the smallest element is at the top 
of the array. Also all the parents’ values must be smaller than heir children.

# Procedures

## Build
This function takes an array and creates a minheap of it. It returns the address 
of the min heap in r1 register.

To implement this, firstly a copy of the array is created. Copying is continued 
until the stopping criteria, -MAXINT is encountered. While copying the 
elements, the total number of elements is also counted. This way, at the end of 
the copying code, the element count is stored in the first element of the heap 
array.
After copying, the heapify procedure will be called. Since the implementation 
of minheap is iterative, the index starts from length of the array and continues
until it is 0. In each iteration, PC branches to heapify procedure. At the end of 
the build procedure the address is copied to r1 register.


## Heapify
In heapify procedure r0 passes the length of the array, r1 passes the address 
and r2 passes the index. While the index is smaller than the length, the 
procedure compares the index’ children to itself and finds the smallest 
element. If there’s a smaller element than the index, swapping is performed. If 
swap happens, the procedure will start to iterate over new element to find if 
the changes affected heapify properties. This method is called for all array 
elements of the array which is wanted to be a heap.


## Sort
This procedure takes a heap and sorts it. The length is in r0, and the address is
in r1. Since this is a minheap, the elements will be sorted in descending order.
And because the given parameter is already a heap, there is no need to call 
build procedure. 
In this procedure, we start from 1st element assuming the 0th element holds the 
heap size. Firstly the first element is swapped with the last element. Now that 
the smallest element is at the end, a heapify procedure is performed to re-
heapify the elements except for the last element. This is repeated until all 
elements are sorted.


## Find
This procedure find the given element in a heap. 
The procedure firstly sorts the heap using sort procedure. After sorting, since 
the elements are in descending order it starts a binary search. If the searched 
value is greater, it jumps to the left part of the array and vice versa. If it finds 
the element r0 becomes 1. After binary search, the procedure loops through 
the heap given to find the address of the found element if r0 is equal to 1. It 
returns the address of the found element in r1.


# REFERENCES
• Non-recursive method of heap sort - Programmer Sought. (n.d.). ProgrammerSought. 
https://www.programmersought.com/article/74205426642/

• How to write the Max Heap code without recursion. (2014, October 10). Stack 
Overflow. https://stackoverflow.com/questions/26293303/how-to-write-the-max-heapcode-without-recursion

• GeeksforGeeks. (2020, February 17). Heap Sort for decreasing order using min heap. 
https://www.geeksforgeeks.org/heap-sort-for-decreasing-order-using-min-heap
