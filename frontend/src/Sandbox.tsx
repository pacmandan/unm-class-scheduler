//import { useDispatch } from 'react-redux';
//import { fetchResults } from './features/search';
//import { fetchInitReference } from "./features/formReference";
import { useEffect } from 'react';
//import { AppDispatch } from './store';
import ScheduleSearch from './ScheduleSearch';
import SearchForm from './SearchForm';

const Sandbox = () => {
  //const dispatch = useDispatch<AppDispatch>()

  useEffect(() => {
    //dispatch(fetchResults({}))
    //dispatch(fetchInitReference())
  }, [])
  return (<div>
    <h1>Sandbox!</h1><br/>
    <div className='flex-auto h-auto w-auto'>
      <SearchForm />
      <ScheduleSearch />
    </div>
  </div>)
}

// bg-red-950

export default Sandbox