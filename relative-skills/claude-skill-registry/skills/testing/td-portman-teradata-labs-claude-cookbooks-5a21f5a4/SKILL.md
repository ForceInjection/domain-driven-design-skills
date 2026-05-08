---
name: td-portman
description: Ljung-Box portmanteau tests for model diagnostics and residual analysis
---

# Teradata Ljung-Box Test

| **Skill Name** | Teradata Ljung-Box Test |
|----------------|--------------|
| **Description** | Ljung-Box portmanteau tests for model diagnostics and residual analysis |
| **Category** | Uaf Model Preparation |
| **Function** | TD_PORTMAN |
| **Framework** | Teradata Unbounded Array Framework (UAF) |

## Core Capabilities

- **Advanced UAF implementation** with optimized array processing
- **Scalable time series analysis** for millions of products or billions of IoT sensors
- **High-dimensional data support** for complex analytical use cases
- **Production-ready SQL generation** with proper UAF syntax
- **Comprehensive error handling** and data validation
- **Business-focused interpretation** of analytical results
- **Integration with UAF pipeline** workflows

## Unbounded Array Framework (UAF) Overview

The Unbounded Array Framework is Teradata's analytics framework for:
- **End-to-end time series forecasting pipelines**
- **Digital signal processing** for radar, sonar, audio, and video
- **4D spatial analytics** and image processing
- **Scalable analysis** of high-dimensional data
- **Complex use cases** across multiple industries

UAF functions process:
- **One-dimensional series** indexed by time or space
- **Two-dimensional arrays** (matrices) indexed by time, space, or both
- **Large datasets** with robust scalability

## Table Analysis Workflow

This skill automatically analyzes your time series data to generate optimized UAF workflows:

### 1. Time Series Structure Analysis
- **Temporal Column Detection**: Identifies time/date columns for indexing
- **Value Column Classification**: Distinguishes between numeric time series values
- **Frequency Analysis**: Determines sampling frequency and intervals
- **Seasonality Detection**: Identifies seasonal patterns and cycles

### 2. UAF-Specific Recommendations
- **Array Dimension Setup**: Configures proper 1D/2D array structures
- **Time Indexing**: Sets up appropriate temporal indexing
- **Parameter Optimization**: Suggests optimal parameters for TD_PORTMAN
- **Pipeline Integration**: Recommends complementary UAF functions

### 3. SQL Generation Process
- **UAF Syntax Generation**: Creates proper Unbounded Array Framework SQL
- **Array Processing**: Handles time series arrays and matrices
- **Parameter Configuration**: Sets function-specific parameters
- **Pipeline Workflows**: Generates complete analytical pipelines

## How to Use This Skill

1. **Provide Your Time Series Data**:
   ```
   "Analyze time series table: database.sensor_data with timestamp column and value columns"
   ```

2. **The Skill Will**:
   - Analyze temporal structure and sampling frequency
   - Identify optimal UAF function parameters
   - Generate complete TD_PORTMAN workflow
   - Provide performance optimization recommendations

## Input Requirements

### Data Requirements
- **Time series table**: Teradata table with temporal data
- **Timestamp column**: Time/date column for temporal indexing
- **Value columns**: Numeric columns for analysis
- **Model inputs**: Previously fitted models or parameters
- **Validation data**: Test datasets for model assessment

### Technical Requirements
- **Teradata Vantage** with UAF (Unbounded Array Framework) enabled
- **UAF License**: Access to time series and signal processing functions
- **Database permissions**: CREATE, DROP, SELECT on working database
- **Function access**: TD_PORTMAN

## Output Formats

### Generated Results
- **UAF-processed arrays** with temporal/spatial indexing
- **Analysis results** specific to TD_PORTMAN functionality
- **Analytical outputs** from function execution
- **Diagnostic metrics** and validation results

### SQL Scripts
- **Complete UAF workflows** ready for execution
- **Parameterized queries** optimized for your data structure
- **Array processing** with proper UAF syntax

## Uaf Model Preparation Use Cases Supported

1. **Model diagnostics**: Advanced UAF-based analysis
2. **Residual testing**: Advanced UAF-based analysis
3. **Autocorrelation testing**: Advanced UAF-based analysis
4. **Model validation**: Advanced UAF-based analysis

## Key Parameters for TD_PORTMAN

- **Lags**: Function-specific parameter for optimal results
- **ConfidenceLevel**: Function-specific parameter for optimal results
- **TestType**: Function-specific parameter for optimal results

## UAF Best Practices Applied

- **Array dimension optimization** for performance
- **Temporal indexing** with proper time series structure
- **Parameter tuning** specific to TD_PORTMAN
- **Memory management** for large-scale data processing
- **Error handling** for UAF-specific scenarios
- **Pipeline integration** with other UAF functions
- **Scalability considerations** for production workloads

## Example Usage

```sql
-- Example TD_PORTMAN workflow
-- Replace parameters with your specific requirements

-- 1. Data preparation for UAF processing
SELECT * FROM TD_UNPIVOT (
    ON your_database.your_timeseries_table
    USING
    TimeColumn ('timestamp_col')
    ValueColumns ('value1', 'value2', 'value3')
) AS dt;

-- 2. Execute TD_PORTMAN
SELECT * FROM TD_PORTMAN (
    ON prepared_data
    USING
    -- Function-specific parameters
    -- (Detailed parameters provided by skill analysis)
) AS dt;
```

## Scripts Included

### Core UAF Scripts
- **`uaf_data_preparation.sql`**: UAF-specific data preparation
- **`td_portman_workflow.sql`**: Complete TD_PORTMAN implementation
- **`table_analysis.sql`**: Time series structure analysis
- **`parameter_optimization.sql`**: Function parameter tuning

### Integration Scripts
- **`uaf_pipeline_template.sql`**: Multi-function UAF workflows
- **`performance_monitoring.sql`**: UAF execution monitoring
- **`result_interpretation.sql`**: Output analysis and visualization

## Industry Applications

### Supported Domains
- **Economic forecasting** and financial analysis
- **Sales forecasting** and demand planning
- **Medical diagnostic** image analysis
- **Genomics and biomedical** research
- **Radar and sonar** analysis
- **Audio and video** processing
- **Process monitoring** and quality control
- **IoT sensor data** analysis

## Limitations and Considerations

- **UAF licensing**: Requires proper Teradata UAF licensing
- **Memory requirements**: Large arrays may require memory optimization
- **Computational complexity**: Some operations may be resource-intensive
- **Data quality**: Results depend on clean, well-structured time series data
- **Parameter sensitivity**: Function performance depends on proper parameter tuning
- **Temporal consistency**: Irregular sampling may require preprocessing

## Quality Checks

### Automated Validations
- **Time series structure** verification
- **Array dimension** compatibility checks
- **Parameter validation** for TD_PORTMAN
- **Memory usage** monitoring
- **Result quality** assessment

### Manual Review Points
- **Parameter selection** appropriateness
- **Result interpretation** accuracy
- **Performance optimization** opportunities
- **Integration** with existing workflows

## Updates and Maintenance

- **UAF compatibility**: Tested with latest Teradata UAF releases
- **Performance optimization**: Regular UAF-specific optimizations
- **Best practices**: Updated with UAF community recommendations
- **Documentation**: Maintained with latest UAF features
- **Examples**: Real-world UAF use cases and scenarios

---

*This skill provides production-ready uaf model preparation analytics using Teradata's Unbounded Array Framework TD_PORTMAN with industry best practices for scalable time series and signal processing.*
