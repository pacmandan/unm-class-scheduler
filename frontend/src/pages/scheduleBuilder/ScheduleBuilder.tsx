import SearchForm from './SearchForm';
import ScheduleCalendar from './ScheduleCalendar';
import SearchResults from './SearchResults';
import SelectedSections from './SelectedSections';

const ScheduleBuilder = () => {
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