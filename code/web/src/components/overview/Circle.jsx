import {
  Box,
  Card,
  CardContent,
  CardHeader,
  Grid,
  Stack,
  Typography,
} from '@mui/material'
import {Chart} from '../chart.jsx'
import React from 'react'

const useChartOptions = labels => {
  return {
    chart: {
      background: 'transparent',
    },
    colors: [
      '#FF6900',
      '#F47373',
      '#697689',
      '#37D67A',
      '#2CCCE4',
      '#FF9F00',
      '#FF5050',
      '#8A9CA9',
      '#3CBF7A',
      '#23B3DD',
      '#FFC300',
      '#FF7171',
      '#546E87',
      '#2ABD8E',
      '#0F9CD7',
    ],
    dataLabels: {
      enabled: false,
    },
    labels,
    legend: {
      show: false,
    },
    plotOptions: {
      pie: {
        expandOnClick: false,
      },
    },
    states: {
      active: {
        filter: {
          type: 'none',
        },
      },
      hover: {
        filter: {
          type: 'none',
        },
      },
    },
    stroke: {
      width: 0,
    },
    theme: {
      mode: 'light',
    },
    tooltip: {
      fillSeriesColor: false,
    },
  }
}

export const Circle = props => {
  const {chartSeries, labels, sx, label} = props
  const chartOptions = useChartOptions(labels)

  return (
    <Card sx={sx}>
      <CardHeader title={label} />
      <CardContent>
        <Grid container columnSpacing={1}>
          <Grid xs={3}>
            <React.Suspense fallback={null}>
              <Chart
                height={300}
                options={chartOptions}
                series={chartSeries}
                type="donut"
                width="100%"
              />
            </React.Suspense>
          </Grid>
          <Grid xs={9}>
            {/* alignItems="center"
            direction="column"
            justifyContent="left"
            spacing={2}
            sx={{mt: 2}} */}
            {/* <Stack>
              {chartSeries?.map((item, index) => {
                const label = labels[index]
                return (
                  <Box
                    key={label}
                    sx={{
                      display: 'flex',
                      flexDirection: 'row',
                      alignItems: 'center',
                    }}>
                    <Typography sx={{my: 1}} variant="span">
                      {label}
                    </Typography>
                    <Typography color="text.secondary" variant="span">
                      : {item}%
                    </Typography>
                  </Box>
                )
              })}
            </Stack> */}
            <Grid container spacing={2}>
              {chartSeries?.map((item, index) => {
                const label = labels[index]
                return (
                  <Grid item xs={4} key={label}>
                    <Box
                      sx={{
                        display: 'flex',
                        flexDirection: 'row',
                        alignItems: 'center',
                        justifyContent: 'center',
                        marginTop: '5px',
                      }}>
                      <Typography sx={{my: 1}} variant="span">
                        {label}
                      </Typography>
                      <Typography color="text.secondary" variant="span">
                        : {item}%
                      </Typography>
                    </Box>
                  </Grid>
                )
              })}
            </Grid>
          </Grid>
        </Grid>
      </CardContent>
    </Card>
  )
}
