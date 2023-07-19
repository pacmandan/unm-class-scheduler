import ScheduleSearch from './ScheduleSearch';
import SearchForm from './SearchForm';

const ScheduleBuilder = () => {
  return (<div className='h-auto w-auto'>
      <SearchForm />
      <ScheduleSearch />
  </div>)
}

export default ScheduleBuilder