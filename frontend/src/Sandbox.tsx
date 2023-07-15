import { useDispatch } from 'react-redux';
import { fetchResults } from './features/search';
import { useEffect } from 'react';
import { AppDispatch } from './store';
import ScheduleSearch from './ScheduleSearch';

const Sandbox = () => {
  const dispatch = useDispatch<AppDispatch>()

  useEffect(() => {
    dispatch(fetchResults({}))
  }, [])
  return (<div>
    <h1>Sandbox!</h1><br/>
    <div className='flex-auto bg-red-950 h-auto w-auto'>
      <ScheduleSearch />
    </div>
  </div>)
}

export default Sandbox