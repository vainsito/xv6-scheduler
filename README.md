# XV6-RISCV Scheduler Analysis and MLFQ Implementation

## Part 1: Studying the xv6-riscv Scheduler and Answering Questions

### Scheduler Code Analysis
1. **Scheduling Policy:**
   - Identify the scheduling policy used by xv6-riscv to choose the next process to execute.
2. **Quantum Duration:**
   - Determine the duration of a quantum in xv6-riscv.
3. **Context Switch Duration:**
   - Find out how long a context switch takes in xv6-riscv.
4. **Context Switch Impact on Quantum:**
   - Investigate if a context switch consumes time from a quantum.
5. **Reducing Process Time Allocation:**
   - Explore if there is a way to allocate less time to a process (hint: start from the system call uptime).
6. **Process States:**
   - Identify the states a process can remain in xv6-riscv and the factors causing state transitions.

## Part 2: Counting Process Selections and Analyzing Scheduler Impact

### Development Activities
- Incorporate a counter into the `struct proc` to track how many times a process is selected by the scheduler.

### Modifications to procdump Function
- Modify the `procdump` function to print the selection counter in addition to its regular output.
- Create a system call `pstat(pid)` that takes a process ID and returns its priority, the number of times it was selected by the scheduler, and the last time it was executed.

### Integration of User-Space Programs
- Integrate user-space programs `iobench` and `cpubench` into xv6-riscv for I/O and computational performance measurements.

### Experimentation and Graphing
- Measure I/O response and computing power for 3 minutes for various cases.
  - Case 1: Run 1 `iobench` alone.
  - Case 2: Run 1 `cpubench` alone.
  - Case 3: Run 1 `iobench` with 1 `cpubench` in parallel.
  - Case 4: Run 1 `cpubench` with 1 `cpubench` in parallel.
  - Case 5: Run 1 `cpubench` with 1 `cpubench` and 1 `iobench` in parallel.
- Repeat the experiment with 10 times shorter quantums.

## Part 3: Tracking Process Priorities

### MLFQ 
- In branch named `mlfq` in the repository.
- Adding a priority field to `struct proc` to track the process priority (ranging from 0 to NPRIO-1, with 0 as the minimum priority and NPRIO-1 as the maximum).
- Update the priority based on process behavior, implementing MLFQ rules.
  - MLFQ Rule 3: Set the priority to the maximum when a process starts.
  - MLFQ Rule 4: Decrease priority when a process completes a quantum of computation; increase priority when a process blocks before completing its quantum.

### procdump Modification
- Modify the `procdump` function to print the priority of processes.

## Part 4: Implementing MLFQ

### MLFQ Implementation
- Modify the scheduler to select the next process based on MLFQ rules.
  - MLFQ Rule 1: Run the process with higher priority.
  - MLFQ Rule 2: If two processes have the same priority, run the one selected fewer times by the scheduler.
- Repeat the measurements from Part 2 to observe the properties of the new scheduler.
- Analyze: Can starvation occur in the new scheduler? Justify your response.

Feel free to modify this Markdown code to better suit your documentation needs.
