import SearchResults from './SearchResults';
import ScheduleCalendar from './ScheduleCalendar';
const ScheduleSearch = () => {
  return (<div className='flex'>
    <ScheduleCalendar />
    <div className='flex'>
      <div className='flex-auto overflow-y-auto h-screen'>
        <SearchResults />
      </div>
    </div>
</div>)
}

export default ScheduleSearch;