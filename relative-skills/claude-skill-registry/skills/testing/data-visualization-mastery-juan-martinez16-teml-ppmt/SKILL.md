---
name: 'Data Visualization Mastery'
description: 'Energy-specific charts: project timelines, cost breakdowns, financial projections, geospatial maps. Interactive dashboards for investment decisions.'
enabled: true
---

# DATA VISUALIZATION MASTERY

## Charts & Dashboards for Oil and Gas Investment Analysis

### 📊 ESSENTIAL CHART TYPES FOR OIL & GAS

**Project Timeline Charts (Gantt)**

- Drilling phases: Spud → TD → Completion → Production
- Development schedule: Subsea installation → FPSO arrival → Commissioning
- Well intervention timeline: Planning → Rig arrival → Operations → Completion
- Critical path highlighting: Dependencies, critical vs. non-critical phases
- Milestone markers: Regulatory approvals, equipment deliveries

**Cost Analysis Charts**

- Stacked bar: CAPEX breakdown (wells, subsea, topsides, drilling)
- Pie chart: Cost distribution (% of total)
- Waterfall: Cost components flowing to total (add, subtract)
- Cost per unit: $/Bbl for lifecycle analysis
- Cost growth: Actuals vs. budget with variance highlighting

**Financial Projection Charts**

- NPV curve: Shows discount rate sensitivity (X-axis: rate, Y-axis: NPV)
- Cash flow waterfall: Annual inflows minus outflows
- Production forecast: Bbls/day declining over time
- Revenue vs. expense: Stacked area chart showing profitability window
- Break-even analysis: When cumulative cash flow turns positive

**Risk & Sensitivity Charts**

- Tornado chart: Ranked sensitivity (oil price impact largest bar)
- Scatter plot: Risk (X) vs. reward (Y) for multiple projects
- Probability distribution: Monte Carlo results histogram
- Sensitivity heatmap: NPV vs. two variables (oil price + production)

**Geospatial Maps**

- Field location map: Lat/lon markers for wells, facilities
- Subsea infrastructure: Manifolds, umbilicals, pipelines
- Production routes: From wellhead → export
- Regional context: Country boundaries, water depth contours

### 🛠️ LIBRARY RECOMMENDATIONS & PATTERNS

**Chart.js** (Fast, Production Dashboards)

- Best for: Line, bar, area, pie charts
- Performance: Handles 1000s of data points smoothly
- Reactivity: Re-render on data change without lag
- Integration: React wrapper (react-chartjs-2)
- Use case: Production forecasts, cost breakdowns, monthly dashboards

**D3.js** (Custom Complex Visualizations)

- Best for: Tornado charts, custom layouts, advanced interactions
- Steep learning curve but unlimited customization
- Approach: Build reusable D3 components
- Use case: Sensitivity analysis, advanced financial visualizations

**Plotly** (Financial & Scientific Charts)

- Best for: NPV curves, confidence intervals, hover interactivity
- Libraries: plotly.js or react-plotly.js
- Rich tooltips: Show detailed data on hover
- 3D support: For complex subsea infrastructure
- Use case: Financial analysis, scientific data display

**Mapbox** (Geospatial Oil and Gas Infrastructure)

- Best for: Field maps, subsea layout visualization
- Zoom/pan: Interactive exploration
- Custom layers: Wells as red dots, facilities as blue squares
- Heat maps: Production by region
- Use case: Asset portfolio view, field development planning

**Recharts** (React-Native Charting)

- Best for: Simple to medium complexity charts with React integration
- Responsive: Auto-scales to container
- Animations: Smooth transitions on data update
- Use case: Responsive dashboards, mobile-friendly charts

### 📈 IMPLEMENTATION PATTERNS

**Responsive Chart Container**

```javascript
// Charts adapt to parent container width
<ResponsiveContainer width="100%" height={400}>
  <LineChart data={data}>
    <XAxis dataKey="year" />
    <YAxis />
    <Tooltip formatter={(val) => `$${val}M`} />
    <Legend />
    <Line type="monotone" dataKey="revenue" stroke="#208090" />
  </LineChart>
</ResponsiveContainer>
```

**Interactive Drill-Down**

- Click chart segment → Filter dashboard below
- Breadcrumb navigation: Show drill-down path
- Restore button: Return to original view
- Example: Click cost bar → See cost detail by subsystem

**Real-Time Data Updates**

- Websocket connection: New data pushed to client
- Chart re-renders: Smooth animation to new values
- History: Keep last 30 days visible, scroll horizontally
- No page refresh: Users stay focused on analysis

**Export Capabilities**

- PNG download: Chart snapshot for presentations
- SVG export: Vector format for printing
- Data download: Raw CSV of chart data
- PDF report: Multi-chart layout on single page

**Performance Optimization**

- Data aggregation: Show every 10th point if > 5000 points
- Virtual scrolling: Only render visible chart areas
- Canvas rendering: Use canvas instead of SVG for 10k+ points
- Lazy loading: Only fetch chart data when tab clicked

### 🎨 VISUAL BEST PRACTICES

**Color Strategy**

- Sequential data (production decline): Blue → light blue (continuous)
- Diverging data (variance): Red (down) → Green (up)
- Multiple series: Distinct colors (teal, slate, red, gold)
- Status colors: Green (good), amber (caution), red (risk)

**Labels & Legends**

- Always show units: "$M", "Bbls/day", "%"
- Currency formatting: $1,234.5M not 1234500000
- Percentage: 85.2% not 0.852
- Large numbers: 1.2B not 1200000000
- Legend position: Right side or bottom, never overlapping data

**Annotations & Context**

- Break-even point: Horizontal line with label
- Important dates: Vertical line (FID date, production start)
- Zones: Shaded area for development phase, production phase
- Target line: Planned vs. actual comparison

### 📱 MOBILE OPTIMIZATION

**Responsive Design**

- Desktop: Full legend, all axes, interactive tooltips
- Tablet: Simplified legend, touch-friendly points
- Mobile: Chart only, legend below, tap for detail

**Touch Interactions**

- Long press: Show detailed tooltip
- Swipe: Scroll through time series data
- Pinch: Zoom in/out (for time series)
- Tap: Drill down or filter

### 🔄 DATA MANAGEMENT

**State Management**

- Chart state: Selected filters, zoom level, visible series
- Data caching: Cache API responses, update on refresh
- Filtering: Date range, project filter, scenario selector
- Comparison mode: Side-by-side of two scenarios

**Real-Time Updates**

- Polling: Fetch new data every 30 seconds
- Websockets: Live push of data changes
- Graceful degradation: Show stale data if connection lost
- Sync indicator: Show "Last updated 2 mins ago"

```

```