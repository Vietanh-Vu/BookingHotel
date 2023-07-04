import {makeStyles} from '@mui/styles'
import {useEffect, useState} from 'react'
import {useNavigate, useParams} from 'react-router-dom'
import {
  Paper,
  TableBody,
  TableRow,
  TableCell,
  Toolbar,
  InputAdornment,
  Checkbox,
  FormControlLabel,
  FormControl,
} from '@mui/material'
import axios from 'axios'
import jwt_decode from 'jwt-decode'
import SearchIcon from '@mui/icons-material/Search'
import GroupIcon from '@mui/icons-material/Group'
import CloseIcon from '@mui/icons-material/Close'
import Controls from '../../components/controls/Controls.jsx'
import AddIcon from '@mui/icons-material/Add'
import NavBar from '../../components/NavBar.jsx'
import {pages} from '../Var.jsx'
import PageHeader from '../../components/PageHeader.jsx'
import useTable from '../../components/useTable.jsx'
import {getAllUsers} from '../../redux/apiRequest.js'
import {useDispatch, useSelector} from 'react-redux'
import {loginSuccess} from '../../redux/authSlice.js'
import { createAxios } from '../../createInstance.js'

const useStyles = makeStyles(theme => ({
  pageContent: {
    marginLeft: '64px',
    marginRight: '64px',
    padding: '16px',
  },
  searchInput: {
    width: '75%',
  },
  newButton: {
    left: '40px',
  },
  filterActive: {
    left: '40px',
  },
}))

const headCells = [
  {
    id: 'fullName',
    disablePadding: false,
    label: 'Full Name',
  },
  {
    id: 'email',
    disablePadding: false,
    label: 'Email',
  },
  {
    id: 'phone',
    disablePadding: false,
    label: 'Phone',
  },
  {
    id: 'address',
    disablePadding: false,
    label: 'Address',
  },
  {
    id: 'role',
    disablePadding: false,
    label: 'Role',
  },
]

const initialFilters = {
  filterAdmin: false,
}

export default function Rooms() {
  const classes = useStyles()
  const [recordForEdit, setRecordForEdit] = useState(null)
  const [records, setRecords] = useState([])
  const [openPopup, setOpenPopup] = useState(false)
  const [filter, setFilter] = useState(initialFilters)
  const [filterFn, setFilterFn] = useState({
    fn: items => {
      return items?.filter(item => item.IsAdmin || !filter.filterAdmin)
    },
  })
  const navigate = useNavigate()
  const dispatch = useDispatch()
  const user = useSelector(state => state.auth.login?.currentUser)
  const userList = useSelector(state => state.users.users?.allUsers)
  let axiosJWT = createAxios(user, dispatch, loginSuccess);

  useEffect(() => {
    if (!user) {
      navigate('/admin/login')
    }
    getAllUsers(user?.accessToken, dispatch, axiosJWT);
    setRecords(userList);
  }, [])

  useEffect(() => {
    setRecords(userList)
  }, [userList])

  const {TblContainer, TblHead, TblPagination, recordsAfterPaging} = useTable(
    records,
    headCells,
    filterFn,
  )

  const handleSearch = e => {
    const target = e.target
    setFilterFn({
      fn: items => {
        if (target.value == '') {
          return items?.filter(item => item.IsAdmin || !filter.filterAdmin)
        } else {
          return items?.filter(
            x =>
              (x.FirstName.toLowerCase().includes(target.value) ||
                x.LastName.toLowerCase().includes(target.value)) &&
              (x.IsAdmin || !filter.filterAdmin),
          )
        }
      },
    })
  }

  const handleFilter = e => {
    const {name, checked} = e.target
    setFilter({
      ...filter,
      [name]: checked,
    })
  }

  useEffect(() => {
    setFilterFn({
      fn: items => {
        return items?.filter(item => item.IsAdmin || !filter.filterAdmin)
      },
    })
  }, [filter])

  const deleteAdmin = user => {
    axios
      .put(`http://localhost:8000/admin/users/delete/${user.UsersId}`)
      .then(res => {
        alert(res.data.message)
      })
      .catch(error => console.log(error))
  }

  const setAdmin = user => {
    axios
      .put(`http://localhost:8000/admin/users/set/${user.UsersId}`)
      .then(res => {
        alert(res.data.message)
      })
      .catch(error => console.log(error))
  }

  return (
    <>
      <NavBar page="Users" pages={pages} value={2} />
      <PageHeader
        title="Users"
        subTitle="List of users"
        icon={<GroupIcon fontSize="medium" />}
      />
      <Paper className={classes.pageContent}>
        <Toolbar>
          <Controls.Input
            label="Search Users"
            className={classes.searchInput}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon />
                </InputAdornment>
              ),
            }}
            onChange={handleSearch}
          />
        </Toolbar>
        <TblContainer>
          <TblHead />
          <FormControl>
            <FormControlLabel
              control={
                <Checkbox
                  name="filterAdmin"
                  color="primary"
                  checked={filter.filterAdmin}
                  onChange={handleFilter}
                />
              }
              label="Show Admin"
            />
          </FormControl>
          <TableBody>
            {recordsAfterPaging() &&
              recordsAfterPaging().map(item => (
                <TableRow key={item.UsersId}>
                  <TableCell>{item.FirstName + ' ' + item.LastName}</TableCell>
                  <TableCell>{item.Email}</TableCell>
                  <TableCell>{item.Phone}</TableCell>
                  <TableCell>{item.Address}</TableCell>
                  <TableCell>{item.IsAdmin ? 'Admin' : 'User'}</TableCell>
                  <TableCell>
                    <Controls.ActionButton
                      color="primary"
                      onClick={() => {
                        setAdmin(item)
                      }}>
                      <AddIcon fontSize="small" />
                    </Controls.ActionButton>
                    <Controls.ActionButton
                      color="primary"
                      onClick={() => {
                        deleteAdmin(item)
                      }}>
                      <CloseIcon fontSize="small" />
                    </Controls.ActionButton>
                  </TableCell>
                </TableRow>
              ))}
          </TableBody>
        </TblContainer>
        <TblPagination />
      </Paper>
    </>
  )
}
