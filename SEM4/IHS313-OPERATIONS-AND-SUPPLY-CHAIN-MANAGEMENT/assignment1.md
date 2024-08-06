# IHS 313 Supply chain and Operations Management

## Gowrish I 2022BCS0155

### Process Flow Diagram

1. Identifying the Bottleneck

The bottleneck in a process is the step that takes the longest time and, therefore, limits the overall output rate. From the provided times:

**Steps**
  - Preparation of toys - 8 minutes
  - Pre-treatment - 12 minutes
  - Painting - 20 minutes
  - Drying - 10 minutes
  - Inspection and packing - 5 minutes

The Painting step takes the longest time at 20 minutes. Hence, it is the bottleneck in this process.

2. Assumptions Behind the Computation

  - No Overlapping or Parallel Processing: Each step must be completed before the next step can begin, and there is no parallel processing within a step.
  - Constant Process Times: The time taken for each step is consistent and does not vary.
  - Single Processing Unit per Step: There is only one station or machine for each step, particularly for the painting step.
  - Immediate Availability of Resources: The necessary materials, tools, and personnel are always available, ensuring there are no delays between steps.
  - No Rework or Defects: All toys are processed perfectly without requiring any rework or additional checks beyond the standard inspection and packing.

```mermaid
graph TD;
    A["Step 1: Preparation of toys"]
    B["Step 2: Pre-treatment"]
    C["Step 3: Painting"]
    D["Step 4: Drying"]
    E["Step 5: Inspection and packing"]

    Start-->A;
    A-->B;
    B-->C;
    C-->D;
    D-->E;
    E-->End;

    A-.->"8 minutes";
    B-.->"12 minutes";
    C-.->"20 minutes";
    D-.->"10 minutes";
    E-.->"5 minutes";

```
