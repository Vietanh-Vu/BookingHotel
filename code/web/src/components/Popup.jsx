import React from 'react'
import {Dialog, DialogTitle, DialogContent, Typography} from '@mui/material'
import {makeStyles} from '@mui/styles'
import Controls from './controls/Controls'
import CloseIcon from '@mui/icons-material/Close'

const useStyles = makeStyles(theme => ({
  dialogWrapper: {
    padding: '8px',
    position: 'absolute',
    top: '64px',
  },
  dialogTitle: {
    paddingRight: '0px',
  },
}))

export default function Popup(props) {
  const {title, children, openPopup, setOpenPopup} = props
  const classes = useStyles()

  return (
    <Dialog
      open={openPopup}
      fullScreen
      classes={{paper: classes.dialogWrapper}}>
      <DialogTitle className={classes.dialogTitle}>
        <div style={{display: 'flex'}}>
          <Typography variant="h6" component="div" style={{flexGrow: 1}}>
            {title}
          </Typography>
          <Controls.ActionButton
            color="secondary"
            onClick={() => {
              setOpenPopup(false)
            }}>
            <CloseIcon />
          </Controls.ActionButton>
        </div>
      </DialogTitle>
      <DialogContent dividers>{children}</DialogContent>
    </Dialog>
  )
}
