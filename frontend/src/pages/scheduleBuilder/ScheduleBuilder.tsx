import SearchForm from './SearchForm';
import ScheduleCalendar from './ScheduleCalendar';
import SearchResults from './SearchResults';
import SelectedSections from './SelectedSections';
import { useDispatch } from 'react-redux';
import { useEffect } from 'react';
import { fetchInitReference } from '@/features/formReference'
import { AppDispatch } from '@/store';

const ScheduleBuilder = () => {
  // Fetch initial form state when the page loads
  const dispatch = useDispatch<AppDispatch>()
  useEffect(() => {
    // I'm not entirely sure why this works, but
    // wrapping this in setTimeout prevents calling the server twice.
    // To my knowledge, this is caused by using <React.StrictMode>.
    let getData = setTimeout(() => {
      dispatch(fetchInitReference())
    }, 0)
    return () => clearTimeout(getData)
  }, [dispatch]);

  return (<div style={{'gridTemplateAreas':'"search calendar" "results calendar" "results selected"'}}
    className="grid grid-rows-[50px_1fr_minmax(30%,400px)] grid-cols-[1fr_40%] min-h-[100px] h-full min-w-[1200px] relative">
    <div style={{'gridArea':'search'}}>
      <SearchForm/>
    </div>
    <div style={{'gridArea':'results'}} className='relative w-full'>
      <SearchResults/>
    </div>
    <div style={{'gridArea':'calendar'}}>
      <ScheduleCalendar/>
    </div>
    <div style={{'gridArea':'selected'}} className=''>
      <SelectedSections/>
    </div>
  </div>)

  /*
    <div className='h-auto w-auto'>
      <SearchForm />
      <ScheduleSearch />
    </div>
   */
}

export default ScheduleBuilder