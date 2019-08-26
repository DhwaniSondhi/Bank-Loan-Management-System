# Bank-Loan-Management-System
A loan management system built to experiment and compare message passing techniques (between different processes/threads) in Java and Erlang.

**Two input files:**
- **customers.txt** : list of customers and loan amount required.
- **banks.txt** : list of banks and amount they can lend.

The application is created to depict the bank's loan management environment in which banks and customers are distinct entities, such that each will be modeled as separate task/process. And, we aim to compare the techniques used to pass messages among threads or processes in Java and Erlang.


## Mechanism
- Each customer wants to borrow the amount listed in the input file. At any one time, however, they can only request a maximum of 50 dollars. When they make a request, they will therefore choose a random dollar amount between 1 and 50 for their current loan.
- When they make a request, they will also randomly choose one of the banks as the target.
- Before each request, a customer will wait/sleep a random period between 10 and 100 milliseconds. This is just to ensure that one customer doesn’t take all the money from the banks at once.
- So the customer will make the request and wait for a response from the bank. It will not make another request until it gets a reply about the current request.
- The bank can accept or reject the request. It will reject the request if the loan would reduce its current financial resources below 0. Otherwise, it grants the loan and notifies the customer.
- If the loan is granted, the customer will deduct this amount from its total loan requirement and then randomly choose a bank (possibly the same one) and make another request (again, between 1 and 50 dollars).
- If the loan is rejected, however, the customer will remove that bank from its list of potential lenders, and then submit a new request to the remaining banks.
- This process continues until customers have either received all of their money or they have no available banks left to contact.

A series of info messages will be printed to the screen:
- A customer will indicate that they are making a loan request.
- Banks will indicate whether they have accepted or denied a given request.
- Before the program ends, customers will indicate if they have reached their goal or not.
- Before the program ends, banks will indicate their remaining funds.
- The information will be printed in master process/main thread.

**Two versions:**

- [Erlang version](https://github.com/DhwaniSondhi/Bank-Loan-Management-System/tree/master/erlang)
- [Java version](https://github.com/DhwaniSondhi/Bank-Loan-Management-System/tree/master/java)
